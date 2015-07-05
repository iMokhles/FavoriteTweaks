#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <substrate.h>
#import "MBProgressHUD.h"
#import "UIActionSheet+Blocks.h"

static inline NSString *UCLocalizeEx(NSString *key, NSString *value = nil) {
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:nil];
}

#define UCLocalize(key) UCLocalizeEx(@ key)

static const NSUInteger UIViewAutoresizingFlexibleBoth(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

@interface UIProgressHUD : UIView
- (void) hide;
- (void) setText:(NSString *)text;
- (void) showInView:(UIView *)view;
@end

@interface NSString ( containsCategory )
- (BOOL) containsString: (NSString*) substring;
@end
// - - - - 
@implementation NSString ( containsCategory )

- (BOOL) containsString: (NSString*) substring
{    
    NSRange range = [self rangeOfString : substring];
    BOOL found = ( range.location != NSNotFound );
    return found;
}
@end

@interface Section : NSObject {
    NSString *name_;
    size_t row_;
    size_t count_;
    NSString *localized_;
}

- (NSComparisonResult) compareByLocalized:(Section *)section;
- (Section *) initWithName:(NSString *)name localized:(NSString *)localized;
- (Section *) initWithName:(NSString *)name localize:(BOOL)localize;
- (Section *) initWithName:(NSString *)name row:(size_t)row localize:(BOOL)localize;

- (NSString *) name;
- (void) setName:(NSString *)name;

- (size_t) row;
- (size_t) count;

- (void) addToRow;
- (void) addToCount;

- (void) setCount:(size_t)count;
- (NSString *) localized;

@end

@interface Source : NSObject
- (NSString *) name;
- (NSString *) shortDescription;
- (NSString *) label;
@end

@interface MIMEAddress : NSObject
- (NSString *) name; // name 
- (NSString *) address; // email address
@end

@interface Package : NSObject {
	Source *source_;
	// pkgCache::VerIterator version_;
}

// - (pkgCache::PkgIterator) iterator;
- (void) parse;

- (NSString *) section;
- (NSString *) simpleSection;

- (NSString *) longSection;
- (NSString *) shortSection;

- (NSString *) uri;

- (MIMEAddress *) maintainer;
- (size_t) size;
- (NSString *) longDescription;
- (NSString *) shortDescription;
- (BOOL) uninstalled;
- (BOOL) upgradableAndEssential:(BOOL)essential;
- (NSString *) mode;
- (NSString *) id;
- (NSString *) name;
- (UIImage *) icon;
- (NSString *) homepage;
- (NSString *) depiction;
- (MIMEAddress *) author;
- (bool) isCommercial;
@end

@interface Database : NSObject
- (NSArray *) packages;
+ (Database *) sharedInstance;
- (unsigned) era;
- (Package *) packageWithName:(NSString *)name;
- (NSArray *) sources;
- (Source *) sourceWithKey:(NSString *)key;
- (void) reloadDataWithInvocation:(NSInvocation *)invocation;
@end

@protocol CyteTableViewCellDelegate
- (void) drawContentRect:(CGRect)rect;
@end

@interface CyteTableViewCellContentView : UIView {
    id<CyteTableViewCellDelegate> delegate_;
}

- (id) delegate;
- (void) setDelegate:(id<CyteTableViewCellDelegate>)delegate;

@end

@interface CyteTableViewCell : UITableViewCell {
    CyteTableViewCellContentView *content_;
    bool highlighted_;
}

@end

@interface PackageCell : CyteTableViewCell {
	UIImage *icon_;
    NSString *name_;
    NSString *description_;
    bool commercial_;
    NSString *source_;
    UIImage *badge_;
    UIImage *placard_;
    bool summarized_;
}
- (PackageCell *) init;
- (void) setPackage:(Package *)package asSummary:(bool)summary;
- (void) drawContentRect:(CGRect)rect;
@end

@interface CyteViewController : UIViewController
@end

@interface CyteWebViewController : CyteViewController
@end

@interface CydiaWebViewController : CyteWebViewController
@end

@interface CYPackageController : CydiaWebViewController {
	 Package *package_;
	 NSString *name_;
	 bool commercial_;
	 UIBarButtonItem *button_;
}
- (id) initWithDatabase:(Database *)database forPackage:(NSString *)name withReferrer:(NSString *)referrer;
- (void) _customButtonClicked;
@end

@interface HomeController : CydiaWebViewController
@end

@interface PackageListController : CyteViewController <
    UITableViewDataSource,
    UITableViewDelegate
> {
    Database *database_;
    unsigned era_;
    NSArray *packages_;
    NSArray *sections_;
    UITableView *list_;

    NSArray *thumbs_;
    NSInteger offset_;

    NSString *title_;
    unsigned reloading_;
}

- (id) initWithDatabase:(Database *)database title:(NSString *)title;
- (void) setDelegate:(id)delegate;
- (void) resetCursor;
- (void) clearData;

- (NSArray *) sectionsForPackages:(NSMutableArray *)packages;

@end

@interface FilteredPackageListController : PackageListController

- (id) initWithDatabase:(Database *)database title:(NSString *)title filter:(id)filter;

- (void) setFilter:(id)filter;
- (void) setSorter:(id)sorter;
@end

typedef void(^finishedWithPackage)(Package *package);
@interface SearchController : FilteredPackageListController <
    UISearchBarDelegate
> {
    UISearchBar *search_;
    BOOL searchloaded_;
    bool summary_;
}

- (id) initWithDatabase:(Database *)database query:(NSString *)query;
- (void) reloadData;
- (finishedWithPackage)getPackageBlock;
- (void)setFinishedWithPackage:(finishedWithPackage)getPackageBlock;
- (void) useSearch;

- (void) usePrefix:(NSString *)prefix;
- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar;
- (void) searchBarButtonClicked:(UISearchBar *)searchBar;
- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar;
- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar;
- (void)createLib_Path;
- (NSString *)packagePlist_Path;
- (NSString *)plist_Folder_Path;
@end

@interface Cydia : UIApplication
- (void) loadData;
- (void) returnToCydia;
- (void) saveState;
- (void) retainNetworkActivityIndicator;
- (void) releaseNetworkActivityIndicator;
- (void) clearPackage:(Package *)package;
- (void) installPackage:(Package *)package;
- (void) installPackages:(NSArray *)packages;
- (void) removePackage:(Package *)package;
- (void) beginUpdate;
- (BOOL) updating;
- (bool) requestUpdate;
- (void) distUpgrade;
- (void) loadData;
- (void) updateData;
- (void) _saveConfig;
- (void) syncData;
- (void) addSource:(NSDictionary *)source;
- (void) addTrivialSource:(NSString *)href;
- (UIProgressHUD *) addProgressHUD;
- (void) removeProgressHUD:(UIProgressHUD *)hud;
- (void) showActionSheet:(UIActionSheet *)sheet fromItem:(UIBarButtonItem *)item;
- (void) reloadDataWithInvocation:(NSInvocation *)invocation;
@end

/* Cydia NSString Additions {{{ */
@interface NSString (Cydia)
- (NSComparisonResult) compareByPath:(NSString *)other;
- (NSString *) stringByAddingPercentEscapesIncludingReserved;
@end

static BOOL isFIleExisteAtPath(NSString *path) {
	return [[NSFileManager defaultManager] fileExistsAtPath:path];
} 

// @interface CyFavoritesTweaksTableViewController : UITableViewController <UIAlertViewDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate> {
// 	NSMutableArray *packagesArray;
// 	NSArray *searchArray;
// }
// @end

Cydia *cyAppDelegate;
Database *globalDatabase;
NSArray *searchArray;

// BOOL isFavTweak = YES;
%hook Cydia
- (void) reloadDataWithInvocation:(NSInvocation *)invocation {
	cyAppDelegate = self;
	%orig;
	globalDatabase = MSHookIvar<Database *>(self, "database_");
	searchArray = [globalDatabase packages];

}
// - (CyteViewController *) pageForURL:(NSURL *)url forExternal:(BOOL)external withReferrer:(NSString *)referrer {
// 	isFavTweak = NO;
// 	return %orig;
// }
%end

// %hook SearchController

// - (void)viewWillAppear:(BOOL)animated {
// 	%orig;
// 	if (isFavTweak) {
// 		MSHookIvar<BOOL>(self, "searchloaded_") = YES;
// 		[MSHookIvar<UISearchBar *>(self, "search_") setFrame:CGRectMake(0, 0, [[self view] bounds].size.width, 44.0f)];
// 		[MSHookIvar<UISearchBar *>(self, "search_") layoutSubviews];

// 		MSHookIvar<UITableView *>(self, "list_").tableHeaderView = MSHookIvar<UISearchBar *>(self, "search_");

// 		UIBarButtonItem *myButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closeSearchController)];
// 		self.navigationItem.rightBarButtonItem = myButton;
// 	}
// }
// %new
// - (void)closeSearchController {
// 	[self dismissViewControllerAnimated:YES completion:nil];
// }
// - (void) didSelectPackage:(Package *)package {
//     if (isFavTweak) {
//     	[self dismissViewControllerAnimated:YES completion:nil];
//     } else {
//     	%orig;
//     }
// }
// %end

SearchController *selfOrig;
%subclass FavTweaksSearchController : SearchController

%new
- (void)createLib_Path {
	NSError *cFolderError = nil;
	if (![[NSFileManager defaultManager] fileExistsAtPath:[selfOrig plist_Folder_Path]]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:[selfOrig plist_Folder_Path] withIntermediateDirectories:NO attributes:nil error:&cFolderError]; //Create folder
		if (cFolderError) {
			NSLog(@"[FavoriteTweaks] Error %@", [cFolderError localizedDescription]);
		}
	}
}

%new
- (NSString *)packagePlist_Path {
	NSString *fileName = @"FavoritesPackages.plist";
    NSString *path = [NSString stringWithFormat:@"%@/%@", [selfOrig plist_Folder_Path], fileName];
    return path;

}

%new
- (NSString *)plist_Folder_Path {
	NSString* pathLibrary = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *dataPath = [pathLibrary stringByAppendingPathComponent:[NSString stringWithFormat:@"/FavoriteTweaks"]];
	return dataPath;
}

- (id) initWithDatabase:(Database *)database query:(NSString *)query {
	if ((self = %orig())) {
		selfOrig = (SearchController *)self;
		[selfOrig useSearch];
	}
	return self;
}

- (void) useSearch {
	%orig;
	[selfOrig reloadData];
}

- (void) usePrefix:(NSString *)prefix {
	%orig;
	[selfOrig reloadData];
}
- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [selfOrig clearData];
    [selfOrig usePrefix:[MSHookIvar<UISearchBar *>(selfOrig, "search_") text]];
}

- (void) searchBarButtonClicked:(UISearchBar *)searchBar {
    [MSHookIvar<UISearchBar *>(selfOrig, "search_") resignFirstResponder];
    [selfOrig useSearch];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [MSHookIvar<UISearchBar *>(selfOrig, "search_") setText:@""];
    [selfOrig searchBarButtonClicked:searchBar];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // [selfOrig searchBarButtonClicked:searchBar];
    return;
}

%new
- (NSURL *) navigationURL {
    if ([MSHookIvar<UISearchBar *>(selfOrig, "search_") text] == nil || [[MSHookIvar<UISearchBar *>(selfOrig, "search_") text] isEqualToString:@""])
        return [NSURL URLWithString:@"cydia://search"];
    else
        return [NSURL URLWithString:[NSString stringWithFormat:@"cydia://search/%@", [[MSHookIvar<UISearchBar *>(selfOrig, "search_") text] stringByAddingPercentEscapesIncludingReserved]]];
}

- (NSArray *) termsForQuery:(NSString *)query {
    NSMutableArray *terms = [NSMutableArray arrayWithCapacity:2];
    for (NSString *component in [query componentsSeparatedByString:@" "])
        if ([component length] != 0)
            [terms addObject:component];

    return terms;
}

- (void)_reloadData {
	%orig;
}
- (void) reloadData {
	%orig;
}
- (void)viewWillAppear:(BOOL)animated {
	%orig;
	MSHookIvar<BOOL>(selfOrig, "searchloaded_") = YES;
	[MSHookIvar<UISearchBar *>(selfOrig, "search_") setFrame:CGRectMake(0, 0, [[selfOrig view] bounds].size.width, 44.0f)];
	[MSHookIvar<UISearchBar *>(selfOrig, "search_") layoutSubviews];

	// MSHookIvar<UITableView *>(selfOrig, "list_").tableHeaderView = MSHookIvar<UISearchBar *>(self, "search_");

	UIBarButtonItem *myButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:selfOrig action:@selector(closeSearchController)];
	selfOrig.navigationItem.rightBarButtonItem = myButton;

	[MSHookIvar<UISearchBar *>(selfOrig, "search_") becomeFirstResponder];
}
%new
- (void)closeSearchController {
	[selfOrig dismissViewControllerAnimated:YES completion:nil];
}
- (void) didSelectPackage:(Package *)package {

	[MSHookIvar<UISearchBar *>(selfOrig, "search_") resignFirstResponder];
    [selfOrig dismissViewControllerAnimated:YES completion:^{
    	// selfOrig.getPackageBlock(package);
    	NSLog(@"********** %@", package.id);

		NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:[selfOrig packagePlist_Path]];
		NSArray *arrayCheck = [array copy];
		BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[selfOrig packagePlist_Path]];
		if (fileExists) {
			NSLog(@"Found");
			if (![arrayCheck containsObject:package.id]) {
				NSLog(@"id not Found");
				[array addObject:package.id];
				[array writeToFile:[selfOrig packagePlist_Path] atomically:YES];
				dispatch_async(dispatch_get_main_queue(), ^{
					[[NSNotificationCenter defaultCenter] postNotificationName:@"CyFavPackagesReloadDataNotification" object:nil];
				});
			}
		} else {
			NSLog(@"NOT Found");
			array = [[NSMutableArray alloc] init];
			[array addObject:package.id];
			[array writeToFile:[selfOrig packagePlist_Path] atomically:YES];
			dispatch_async(dispatch_get_main_queue(), ^{
				[[NSNotificationCenter defaultCenter] postNotificationName:@"CyFavPackagesReloadDataNotification" object:nil];
			});
		}
    }];
}
%end

@interface CyFavoritesTweaksTableViewController : UIViewController <UIActionSheetDelegate, UIAlertViewDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate> {
	unsigned era_;
	MBProgressHUD *HUD;
}
// Variables that are required to be set for basic functionality
@property (nonatomic, strong) NSMutableArray *arrayCells;
@property (nonatomic, strong) UITableView *myTableView;
@end

// i don't know why i needs it xP
// @interface CyFavoritesTweaksTableViewController ()
// @end

@implementation CyFavoritesTweaksTableViewController
@synthesize myTableView;

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	// isFavTweak = YES;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadPackagesData) name:@"CyFavPackagesReloadDataNotification" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	// [cyAppDelegate reloadDataWithInvocation:nil];
}
- (void)viewDidLoad{

   [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	[self createLib_Path];

    //Add a edit button
   	self.navigationItem.title = @"Favorites Tweaks";
   	// no need that anymore
 //   	if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
	// {
	//     self.edgesForExtendedLayout = UIRectEdgeNone;
	//     self.extendedLayoutIncludesOpaqueBars = NO;
	// 	self.automaticallyAdjustsScrollViewInsets = NO;
	// } else {
	// 	self.navigationController.navigationBar.translucent = NO;
	// }

	UIView *mainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [mainView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [self setView:mainView];

    self.myTableView = [[UITableView alloc] initWithFrame:[[self view] bounds] style:UITableViewStylePlain];
    [self.myTableView setAutoresizingMask:UIViewAutoresizingFlexibleBoth];
    [self.myTableView setDataSource:self];
    [self.myTableView setDelegate:self];

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.myTableView addSubview:refreshControl];
    [self.myTableView setEditing:NO];
    [self.myTableView setBackgroundColor:[UIColor whiteColor]];
    [mainView addSubview:self.myTableView];

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 50.0f)];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, view.frame.size.height)];
	label.text = @"Favorites Tweaks";
	label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:19];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
	[label sizeToFit];
	label.center = CGPointMake(view.frame.size.width  / 2, view.frame.size.height / 2);
	label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	[view addSubview:label];

    self.myTableView.tableHeaderView = view;

    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[self packagePlist_Path]];

    if (fileExists) {
        self.arrayCells = [NSMutableArray arrayWithContentsOfFile:[self packagePlist_Path]];
        [self.myTableView reloadData];
    }

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action: @selector(addNewPackageForFav)];
    [self.navigationItem setRightBarButtonItem:addButton];

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
	[self.myTableView addGestureRecognizer:longPress];

}

#pragma mark - MBProgressHUDDelegate

- (IBAction)longPressGestureRecognized:(id)sender {
  
  UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
  UIGestureRecognizerState state = longPress.state;
  
  CGPoint location = [longPress locationInView:self.myTableView];
  NSIndexPath *indexPath = [self.myTableView indexPathForRowAtPoint:location];
  
  static UIView       *snapshot = nil;        ///< A snapshot of the row user is moving.
  static NSIndexPath  *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
  
  switch (state) {
    case UIGestureRecognizerStateBegan: {
      if (indexPath) {
        sourceIndexPath = indexPath;
        
        UITableViewCell *cell = [self.myTableView cellForRowAtIndexPath:indexPath];
        
        // Take a snapshot of the selected row using helper method.
        snapshot = [self customSnapshoFromView:cell];
        
        // Add the snapshot as subview, centered at cell's center...
        __block CGPoint center = cell.center;
        snapshot.center = center;
        snapshot.alpha = 0.0;
        [self.myTableView addSubview:snapshot];
        [UIView animateWithDuration:0.25 animations:^{
          
          // Offset for gesture location.
          center.y = location.y;
          snapshot.center = center;
          snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
          snapshot.alpha = 0.98;
          cell.alpha = 0.0;
          
        } completion:^(BOOL finished) {
          
          cell.hidden = YES;
          
        }];
      }
      break;
    }
      
    case UIGestureRecognizerStateChanged: {
      CGPoint center = snapshot.center;
      center.y = location.y;
      snapshot.center = center;
      
      // Is destination valid and is it different from source?
      if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
        
        // ... update data source.
        [self.arrayCells exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
        
        // ... move the rows.
        [self.myTableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
        
        // ... and update source so it is in sync with UI changes.
        sourceIndexPath = indexPath;
      }
      break;
    }
      
    default: {
      // Clean up.
      UITableViewCell *cell = [self.myTableView cellForRowAtIndexPath:sourceIndexPath];
      cell.hidden = NO;
      cell.alpha = 0.0;
      
      [UIView animateWithDuration:0.25 animations:^{
        
        snapshot.center = cell.center;
        snapshot.transform = CGAffineTransformIdentity;
        snapshot.alpha = 0.0;
        cell.alpha = 1.0;
        
      } completion:^(BOOL finished) {
        
        sourceIndexPath = nil;
        [snapshot removeFromSuperview];
        snapshot = nil;
        
      }];
      
      break;
    }
  }
  [self.arrayCells writeToFile:[self packagePlist_Path] atomically:YES];
}

/** @brief Returns a customized snapshot of a given view. */
- (UIView *)customSnapshoFromView:(UIView *)inputView {
  
  // Make an image from the input view.
  UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
  [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
    
  // Create an image view.
  UIView *snapshot = [[UIImageView alloc] initWithImage:image];
  snapshot.layer.masksToBounds = NO;
  snapshot.layer.cornerRadius = 0.0;
  snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
  snapshot.layer.shadowRadius = 5.0;
  snapshot.layer.shadowOpacity = 0.4;
  
  return snapshot;
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	HUD = nil;
}
// don't need it anymore
- (void)packageNotification:(NSNotification *)notification {

}
-(void)handleRefresh:(UIRefreshControl *)refresh {
    [self reloadPackagesData];
    [refresh endRefreshing];
 }

- (void)reloadPackagesData { 
    dispatch_async(dispatch_get_main_queue(), ^{ 
		self.arrayCells = [NSMutableArray arrayWithContentsOfFile:[self packagePlist_Path]];
		[self.myTableView reloadData];
    });
    [self.myTableView endUpdates];
}

- (NSURL *) referrerURL {
    return nil;
}

- (void) didSelectPackage:(Package *)package {
    CYPackageController *view = [[%c(CYPackageController) alloc] initWithDatabase:globalDatabase forPackage:[package id] withReferrer:[[self referrerURL] absoluteString]];
    // [view setDelegate:delegate_];
    [[self navigationController] pushViewController:view animated:YES];
}

// will check it later
// - (void)tableView:(UITableView *)tableView willDisplayCell:(PackageCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
// {
//     cell.backgroundColor = [UIColor clearColor];
//     cell.textLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
//     cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
// }

- (bool) isSummarized {
    return false;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return self.arrayCells.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 73;
}

- (UITableViewCell *) tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PackageCell *cell = (PackageCell *)[table dequeueReusableCellWithIdentifier:@"Package"];
    if (cell == nil)
        cell = [[%c(PackageCell) alloc] init];

    Package *package = [globalDatabase packageWithName:[self.arrayCells objectAtIndex:indexPath.row]];
    cell.showsReorderControl = YES;
    [cell setPackage:package asSummary:[self isSummarized]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    Package *package = [globalDatabase packageWithName:[self.arrayCells objectAtIndex:indexPath.row]];
    [self didSelectPackage:package];
    
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;

}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
            //remove our NSMutableArray
        [self.arrayCells removeObjectAtIndex:indexPath.row];
        [self.arrayCells writeToFile:[self packagePlist_Path] atomically:YES];
            //remove from our tableView
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }


}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {

	Package *package = [globalDatabase packageWithName:[self.arrayCells objectAtIndex:indexPath.row]];
	NSString *moreString;
	if (![package uninstalled]) {
        moreString = UCLocalize("MODIFY");
    } else {
    	moreString = UCLocalize("INSTALL");
    }

    UITableViewRowAction *moreAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:moreString handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        // maybe show an action sheet with more options

        Package *package = [globalDatabase packageWithName:[self.arrayCells objectAtIndex:indexPath.row]];

        UIActionSheet *sheet = [[UIActionSheet alloc]
            initWithTitle:nil
            delegate:self
            cancelButtonTitle:nil // UCLocalize("CANCEL")
            destructiveButtonTitle:nil // UCLocalize("REMOVE")
            otherButtonTitles:nil
        ];
        [sheet setTag:indexPath.row];

        if (![package uninstalled]) {
        	[sheet addButtonWithTitle:UCLocalize("CANCEL")];
        	[sheet addButtonWithTitle:UCLocalize("REMOVE")];
        	[sheet addButtonWithTitle:UCLocalize("REINSTALL")];
        	[sheet addButtonWithTitle:UCLocalize("UPGRADE")];
        	[sheet setCancelButtonIndex:0];
        	[sheet setDestructiveButtonIndex:1];
	        [cyAppDelegate showActionSheet:sheet fromItem:nil];
        } else {
        	[cyAppDelegate installPackage:package];
        }
        [self.myTableView setEditing:NO];
    }];
    moreAction.backgroundColor = [UIColor lightGrayColor];
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        [self.arrayCells removeObjectAtIndex:indexPath.row];
        [self.arrayCells writeToFile:[self packagePlist_Path] atomically:YES];
            //remove from our tableView
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
    
    return @[deleteAction, moreAction];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
	Package *package = [globalDatabase packageWithName:[self.arrayCells objectAtIndex:actionSheet.tag]];

	if  ([buttonTitle isEqualToString:UCLocalize("CANCEL")]) {
	}
	if ([buttonTitle isEqualToString:UCLocalize("REMOVE")]) {
		[cyAppDelegate removePackage:package];
	}
	if ([buttonTitle isEqualToString:UCLocalize("REINSTALL")]) {
		[cyAppDelegate installPackage:package];
	}
	if ([buttonTitle isEqualToString:UCLocalize("UPGRADE")]) {
		[cyAppDelegate installPackage:package];
	}
}
// - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
// {
//     return YES;
// }

// - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath 
// {
//     Package *package = [globalDatabase packageWithName:[self.arrayCells objectAtIndex:fromIndexPath.row]];
//     [self.arrayCells removeObject:package.id];
//     [self.arrayCells insertObject:package.id atIndex:toIndexPath.row];
//     [self.arrayCells writeToFile:[self packagePlist_Path] atomically:YES];
// }

- (void)addNewPackageForFav {

	SearchController *searchCon = (SearchController *)[[%c(FavTweaksSearchController) alloc] initWithDatabase:globalDatabase query:nil];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:searchCon];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)createLib_Path {
	NSError *cFolderError = nil;
	if (![[NSFileManager defaultManager] fileExistsAtPath:[self plist_Folder_Path]]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:[self plist_Folder_Path] withIntermediateDirectories:NO attributes:nil error:&cFolderError]; //Create folder
		if (cFolderError) {
			NSLog(@"[FavoriteTweaks] Error %@", [cFolderError localizedDescription]);
		}
	}
}

- (NSString *)packagePlist_Path {
	NSString *fileName = @"FavoritesPackages.plist";
    NSString *path = [NSString stringWithFormat:@"%@/%@", [self plist_Folder_Path], fileName];
    return path;

}

- (NSString *)plist_Folder_Path {
	NSString* pathLibrary = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *dataPath = [pathLibrary stringByAppendingPathComponent:[NSString stringWithFormat:@"/FavoriteTweaks"]];
	return dataPath;
}

// Private

- (void)showHUDWithText:(NSString *)string {
	HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	
	HUD.delegate = self;
	HUD.labelText = string;
	
	[HUD show:YES];
}

- (UIProgressHUD *) addProgressHUD {
    UIProgressHUD *hud = [[UIProgressHUD alloc] init];
    [hud setAutoresizingMask:UIViewAutoresizingFlexibleBoth];

    [[UIApplication sharedApplication].keyWindow setUserInteractionEnabled:NO];
    [hud showInView:[self view]];
    return hud;
}

- (void) removeProgressHUD:(UIProgressHUD *)hud {
    [hud hide];
    [hud removeFromSuperview];
    [[UIApplication sharedApplication].keyWindow setUserInteractionEnabled:YES];
}


@end



%hook HomeController

// got it from CyteWebViewController class
- (UIBarButtonItem *) customButton {
	UIBarButtonItem *origRightButton; // = MSHookIvar<UIBarButtonItem *>(self, "button_");
	origRightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home7s.png"] style:UIBarButtonItemStylePlain target:self action:@selector(openNewFavPage)];
	UIGraphicsBeginImageContextWithOptions(CGSizeMake(20, 20), NO, 0.0);
	UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	[origRightButton setBackgroundImage:blank forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
	return origRightButton;
}
%new
- (void)openNewFavPage {
	CyFavoritesTweaksTableViewController *favCon = [[CyFavoritesTweaksTableViewController alloc] init];
	[[self navigationController] pushViewController:favCon animated:YES];
}
%end
