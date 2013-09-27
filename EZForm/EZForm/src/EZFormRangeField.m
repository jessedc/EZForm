//
//  EZForm
//
//  Copyright 2011-2013 Chris Miles. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EZFormRangeField.h"
#import "EZForm+Private.h"


#pragma mark - External Class Categories

@interface UIView (EZFormRadioFieldExtension)
@property (readwrite, retain) UIView *inputView;
@end

@interface EZFormTextField (EZFormRadioFieldPrivateAccess)
@property (nonatomic, copy) id internalValue;
- (void)updateUIWithValue:(NSString *)value;
- (void)updateValidityIndicators;
@end


#pragma mark - EZFormRadioField class extension

@interface EZFormRangeField () <UIPickerViewDataSource, UIPickerViewDelegate>
@end

#pragma mark - EZFormRangeFieldSection implementation

@interface EZFormRangeFieldSection()
@property (nonatomic, strong) id selectedKey;
@end

@implementation EZFormRangeFieldSection

+ (instancetype)EZFormRangeFieldSectionWithKey:(NSString *)aKey choices:(NSDictionary *)choices orderedKeys:(NSArray *)keys
{
    EZFormRangeFieldSection *section = [[self alloc] init];
    section.key = aKey;
    section.choices = choices;
    section.orderedKeys = keys;
    section.selectedKey = section.orderedKeys[0];

    return section;
}

- (id)valueForSelectedKey
{
    return self.choices[self.selectedKey];
}

- (NSUInteger)indexOfSelectedKey
{
    return [self.orderedKeys indexOfObject:self.selectedKey];
}

- (NSString *)valueAtIndex:(NSUInteger)index
{
    NSString *key = [self choiceKeyAtIndex:index];
    return self.choices[key];
}

- (NSString *)choiceKeyAtIndex:(NSUInteger)index
{
    return self.orderedKeys[index];
}

@end


#pragma mark - EZFormRageField implementation

@implementation EZFormRangeField

@dynamic inputView;

#pragma mark - EZFormFieldConcrete methods

- (BOOL)typeSpecificValidation
{
    //TODO: JESSE (validation)
    BOOL result = YES;
    
    return result;
}

- (void)updateView
{
    NSString *value = [self fieldDisplayValue];
    [self updateUIWithValue:value];
    [self updateInputViewAnimated:YES];
}

- (NSString *)fieldDisplayValue
{
    //FIXME: have a displayFormatter
    return [NSString stringWithFormat:@"%@ to %@", [self.lowerRange valueForSelectedKey], [self.upperRange valueForSelectedKey]];
}

- (void)setActualFieldValue:(__unused id)value
{
    //don't call super
    self.internalValue = @{ self.key : @{ self.lowerRange.key : [self.lowerRange selectedKey], self.upperRange.key : [self.upperRange selectedKey]} };
}

#pragma mark - Unwire views

- (void)unwireUserViews
{
    [self unwireInputView];
    [super unwireUserViews];
}

- (void)unwireInputView
{
    if ([self.userView.inputView isKindOfClass:[UIPickerView class]]) {
	UIPickerView *pickerView = (UIPickerView *)self.userView.inputView;
	if (pickerView.dataSource == self) pickerView.dataSource = nil;
	if (pickerView.delegate == self) pickerView.delegate = nil;
    }
    
    self.userView.inputView = nil;
}

#pragma mark - inputView

- (void)setInputView:(UIView *)inputView
{
    if (self.userView == nil) {
	NSException *exception = [NSException exceptionWithName:@"Attempt to set inputView with no userView" reason:@"A user view must be set before calling setInputView" userInfo:nil];
	@throw exception;
    }
    if (! [self.userView respondsToSelector:@selector(setInputView:)]) {
	NSException *exception = [NSException exceptionWithName:@"setInputView invalid" reason:@"EZFormRadioField user view does not accept an input view" userInfo:nil];
	@throw exception;
    }
    
    if ([inputView isKindOfClass:[UIPickerView class]]) {
	UIPickerView *pickerView = (UIPickerView *)inputView;
	
	pickerView.showsSelectionIndicator = YES;
	
	// User can elect to handle dataSource or delegate for picker, otherwise we do it automatically
	if (pickerView.dataSource == nil) pickerView.dataSource = self;
	if (pickerView.delegate == nil) pickerView.delegate = self;
    }
    else {
	NSException *exception = [NSException exceptionWithName:@"Unsupported inputView" reason:@"EZFormRadioField only supports wiring up inputViews of type UIPickerView" userInfo:nil];
	@throw exception;
    }
    
    self.userView.inputView = inputView;
    [self updateInputViewAnimated:NO];
}

- (UIView *)inputView
{
    return self.userView.inputView;
}

- (void)updateInputViewAnimated:(BOOL)animated
{
    if ([self.userView.inputView isKindOfClass:[UIPickerView class]]) {
	UIPickerView *pickerView = (UIPickerView *)self.userView.inputView;
	if (self.fieldValue) {
            for (NSUInteger sectionIndex = 0; sectionIndex < 2; sectionIndex++) {
                NSInteger selectedIndex = (NSInteger)[[self sectionForIndex:sectionIndex] indexOfSelectedKey];
                if (selectedIndex != [pickerView selectedRowInComponent:0]) {
                    [pickerView selectRow:selectedIndex inComponent:(NSInteger)sectionIndex animated:animated];
                }
            }
	}
    }
}

- (EZFormRangeFieldSection *)sectionForIndex:(NSUInteger)index
{
    EZFormRangeFieldSection *section;
    if (index == 0) {
        section = self.lowerRange;
    }else if (index == 1) {
        section = self.upperRange;
    }
    return section;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(__unused UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(__unused UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    EZFormRangeFieldSection *section = [self sectionForIndex:(NSUInteger)component];
    return (NSInteger)[section.choices count];
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(__unused UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    EZFormRangeFieldSection *section = [self sectionForIndex:(NSUInteger)component];
    return [section valueAtIndex:(NSUInteger)row];
}

- (void)pickerView:(__unused UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    EZFormRangeFieldSection *section = [self sectionForIndex:(NSUInteger)component];
    section.selectedKey = [section choiceKeyAtIndex:(NSUInteger)row];

    [self setFieldValue:@[self.lowerRange, self.upperRange] canUpdateView:YES];

    [self updateValidityIndicators];
}

@end
