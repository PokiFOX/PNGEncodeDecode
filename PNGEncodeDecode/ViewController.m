//
//  ViewController.m
//  PNGEncodeDecode
//
//  Created by Wei WEI on 2020/2/9.
//  Copyright © 2020 Wei WEI. No rights reserved.
//

#import "ViewController.h"
#import "AES256.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view.

	_Input_Detail.layer.backgroundColor = [[UIColor clearColor] CGColor];
	_Input_Detail.layer.borderColor = [[UIColor grayColor] CGColor];
	_Input_Detail.layer.borderWidth = 1.0;
	[_Input_Detail.layer setMasksToBounds:YES];

	_Label_Help.userInteractionEnabled = YES;
	UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(OnClick_LabelHelp:)];
	[_Label_Help addGestureRecognizer:labelTapGestureRecognizer];
	_Label_Help.hidden = YES;
	
	_Input_Detail.delegate = self;
}

- (IBAction)OnChanged_ShowPwd:(id)sender
{
	if (self.ShowPwd.on) {
		self.Input_Key.secureTextEntry = NO;
	}
	else {
		self.Input_Key.secureTextEntry = YES;
	}
}

- (IBAction)OnClick_Export:(id)sender
{
	NSString* str_key = self.Input_Key.text;
	if (str_key.length == 0) {
		UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Please input key! max length:32" message:@"Error." preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
		[alertController addAction:defaultAction];
		[self presentViewController:alertController animated:YES completion:nil];
		return;
	}
	
	NSString* str_detail = self.Input_Detail.text;
	if (str_detail.length == 0) {
		UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Please input text!" message:@"Error." preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
		[alertController addAction:defaultAction];
		[self presentViewController:alertController animated:YES completion:nil];
		return;
	}
	const char* str_text = [str_detail UTF8String];
	if (strlen(str_text) > 1024) {
		UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"max text length:1024!" message:@"Error." preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
		[alertController addAction:defaultAction];
		[self presentViewController:alertController animated:YES completion:nil];
		return;
	}

	while (str_key.length < KeyLength) {
		str_key = [str_key stringByAppendingString:@" "];
	}
	NSData* detail = [str_detail dataUsingEncoding:NSUTF8StringEncoding];
	NSData* encode = [detail aes256_encrypt:str_key];
	NSString* base64str = [encode base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
	NSData* base64 = [base64str dataUsingEncoding:NSUTF8StringEncoding];
	CIFilter* filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
	[filter setDefaults];
	[filter setValue:base64 forKey:@"inputMessage"];
	CIImage* outputImage = [filter outputImage];
	UIImage* image = [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:ImageSize];
	UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
	UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Save" message:@"Finish." preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
	[alertController addAction:defaultAction];
	[[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (UIImage*)createNonInterpolatedUIImageFormCIImage:(CIImage*)image withSize:(CGFloat) size
{
	CGRect extent = CGRectIntegral(image.extent);
	CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));

	size_t width = CGRectGetWidth(extent) * scale;
	size_t height = CGRectGetHeight(extent) * scale;
	CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
	CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
	CIContext* context = [CIContext contextWithOptions:nil];
	CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
	CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
	CGContextScaleCTM(bitmapRef, scale, scale);
	CGContextDrawImage(bitmapRef, extent, bitmapImage);

	CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
	CGContextRelease(bitmapRef);
	CGImageRelease(bitmapImage);
	return [UIImage imageWithCGImage:scaledImage];
}

- (IBAction)OnClick_Import:(id)sender
{
	NSString* str_key = self.Input_Key.text;

	if (str_key.length == 0) {
		UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Please input key! max length:32" message:@"Error." preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
		[alertController addAction:defaultAction];
		[self presentViewController:alertController animated:YES completion:nil];
		return;
	}

	UIAlertController* alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	
	UIAlertAction* albumAction = [UIAlertAction actionWithTitle:@"Album" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
			[self showPicker:UIImagePickerControllerSourceTypePhotoLibrary];
	}];
	
	UIAlertAction* cameraAction = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
			[self showPicker:UIImagePickerControllerSourceTypeCamera];
	}];
	
	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
	}];
	
	[alertController addAction:albumAction];
	[alertController addAction:cameraAction];
	[alertController addAction:cancelAction];
	
	[[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:^{
	}];
}

- (void)showPicker: (UIImagePickerControllerSourceType)type
{
	UIImagePickerController* picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	picker.sourceType = type;
	picker.allowsEditing = NO;
	[self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
	NSString* str_key = self.Input_Key.text;
	while (str_key.length < KeyLength) {
		str_key = [str_key stringByAppendingString:@" "];
	}
	if (![[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.image"]) return;
	UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
	NSString* scannedResult = @"";
	NSString* str = nil;
	if (image) {
		CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
		NSArray* features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
		if ([features count] > 0) {
			CIQRCodeFeature* feature = [features objectAtIndex:0];
			scannedResult = feature.messageString;
			NSData* base64 = [[NSData alloc] initWithBase64EncodedString:scannedResult options:0];
			NSData* decode = [base64 aes256_decrypt:str_key];
			str  = [[NSString alloc] initWithData:decode encoding:NSUTF8StringEncoding];
			[_Input_Detail setText:str];
		}
	}
	[picker dismissViewControllerAnimated:YES completion:nil];
	if (str == nil) {
		UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Wrong key or qrcode!" message:@"Error." preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
		[alertController addAction:defaultAction];
		[self presentViewController:alertController animated:YES completion:nil];
	}
	else {
		UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Import" message:@"Finish." preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
		[alertController addAction:defaultAction];
		[self presentViewController:alertController animated:YES completion:nil];
	}
}

- (IBAction)DidEndOnExit_Key:(id)sender
{
	[_Input_Key resignFirstResponder];
}

- (IBAction)OnClick_Help:(id)sender {
	_Label_Help.hidden = NO;
}

- (void) OnClick_LabelHelp:(UITapGestureRecognizer*)recognizer
{
	_Label_Help.hidden = YES;
}

- (BOOL)textView:(UITextView*)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
	if ([text isEqualToString:@"\n"]) {
		[_Input_Detail resignFirstResponder];
	}
	return YES;
}

@end
