//
//  OpenWatchViewController.m
//  OpenWatch
//
//  Created by micah on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OpenWatchViewController.h"
#import "OpenWatchAppDelegate.h"

@implementation OpenWatchViewController

@synthesize recordVideoButton;
@synthesize imagePickerController;
@synthesize loadingLabel;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [self setLoadingLabel:nil];
    [self setRecordVideoButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)onRecordVideo:(id)sender {
    NSLog(@"onRecordVideo start");
    
    loadingLabel.text = @"Starting camera...";
    
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    OpenWatchAppDelegate* appDelegate = (OpenWatchAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.window addSubview:imagePickerController.view];
    [appDelegate.window makeKeyAndVisible];
    
    loadingLabel.text = @"";
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"imagePickerConntroller:didFinishPickingMediaWithInfo");
    NSURL *url = [[[info objectForKey:UIImagePickerControllerMediaURL] copy] autorelease];
    ALAssetsLibrary* library = [[[ALAssetsLibrary alloc] init] autorelease];
    [library writeVideoAtPathToSavedPhotosAlbum:url completionBlock:^(NSURL *assetURL, NSError *error){
        NSLog(@"Video saved to: %@", assetURL);
        
        // remove the camera view
        if( imagePickerController ) {
            [imagePickerController.view removeFromSuperview];
            [imagePickerController release];
        }
        

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://openwatch.net/uploadnocaptha"]];
        [request setTimeoutInterval:60.0f];
        
        NSData *data = [NSData dataWithContentsOfURL:assetURL];
        [request setHTTPMethod:@"POST"];	
        [request setValue:@"multipart/form-data; boundary=0xKhTmLbOuNdArY" forHTTPHeaderField:@"Content-Type"];
        
        NSMutableData *postData = [NSMutableData dataWithCapacity:[data length] +512];
        [postData appendData: [@"--0xKhTmLbOuNdArY\r\n" dataUsingEncoding:NSUTF8StringEncoding]];	
        [postData appendData: [@"Content-Disposition: form-data; name=\"id_rec_file\"; filename=\"id_rec_file\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:data];
        [postData appendData: [@"\r\n--0xKhTmLbOuNdArY--\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:postData];

        [NSURLConnection connectionWithRequest:request delegate:self];
        
        
        // alert that it's been saved
        /*
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved"
                                                        message:@"Your video has been saved to your gallery. Stay tuned for updates to post video to the OpenWatch website."
													   delegate:nil
                                              cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
        [alert autorelease];
        [alert show];
         */
    }];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"imagePickerControllerDidCancel");
    if(imagePickerController) {
        [imagePickerController.view removeFromSuperview];
        [imagePickerController release];
    }
}


#pragma mark -
#pragma mark NSURLConnectionDelegate


- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    NSLog(@"didSendBodyData");
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"didReceiveData");    
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");    
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError:%@", error);    
}


#pragma mark -


- (void)dealloc {
    if(imagePickerController) {
        [imagePickerController release];
    }
    
    [loadingLabel release];
    [recordVideoButton release];
    [super dealloc];
}
@end
