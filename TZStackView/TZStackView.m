//
//  TZStackView.m
//  TZStackView
//
//  Created by Kevin Wooten on 10/16/15.
//  Copyright © 2015 Tom van Zummeren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

// ----------------------------------------------------
// Runtime injection start.
// Assemble codes below are based on:
// https://github.com/0xced/NSUUID/blob/master/NSUUID.m
// ----------------------------------------------------

#pragma mark - Runtime Injection

__asm(
      ".section        __DATA,__objc_classrefs,regular,no_dead_strip\n"
#if	TARGET_RT_64_BIT
      ".align          3\n"
      "L_OBJC_CLASS_UIStackView:\n"
      ".quad           _OBJC_CLASS_$_UIStackView\n"
#else
      ".align          2\n"
      "_OBJC_CLASS_UIStackView:\n"
      ".long           _OBJC_CLASS_$_UIStackView\n"
#endif
      ".weak_reference _OBJC_CLASS_$_UIStackView\n"
      );

// Constructors are called after all classes have been loaded.
__attribute__((constructor)) static void TZStackViewPatchEntry(void) {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    @autoreleasepool {
      
      // >= iOS9.
      if (objc_getClass("UIStackView")) {
        return;
      }
      
      Class *stackViewClassLocation = NULL;
      
#if TARGET_CPU_ARM
      __asm("movw %0, :lower16:(_OBJC_CLASS_UIStackView-(LPC0+4))\n"
            "movt %0, :upper16:(_OBJC_CLASS_UIStackView-(LPC0+4))\n"
            "LPC0: add %0, pc" : "=r"(stackViewClassLocation));
#elif TARGET_CPU_ARM64
      __asm("adrp %0, L_OBJC_CLASS_UIStackView@PAGE\n"
            "add  %0, %0, L_OBJC_CLASS_UIStackView@PAGEOFF" : "=r"(stackViewClassLocation));
#elif TARGET_CPU_X86_64
      __asm("leaq L_OBJC_CLASS_UIStackView(%%rip), %0" : "=r"(stackViewClassLocation));
#elif TARGET_CPU_X86
      void *pc = NULL;
      __asm("calll L0\n"
            "L0: popl %0\n"
            "leal _OBJC_CLASS_UIStackView-L0(%0), %1" : "=r"(pc), "=r"(stackViewClassLocation));
#else
#error Unsupported CPU
#endif
      
      if (stackViewClassLocation && !*stackViewClassLocation) {
        Class superclass = NSClassFromString(@"TZStackView") ? NSClassFromString(@"TZStackView") : NSClassFromString(@"TZStackView.TZStackView");
        Class class = objc_allocateClassPair(superclass, "UIStackView", 0);
        if (class) {
          objc_registerClassPair(class);
          *stackViewClassLocation = class;
        }
      }
    }
  });
}
