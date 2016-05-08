//
//  ViewController.m
//  MovieInfoApp
//
//  Created by Justin Madewell on 10/18/15.
//  Copyright © 2015 Justin Madewell. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "JDMTableViewCell.h"
#import "JDMUtility.h"

static NSString* kCell = @"cell";
static NSString* SiteURL = @"http://www.omdbapi.com/?";
static NSString* SiteURL_IMDB = @"http://www.imdbapi.com/?";
static NSString* PosterURL =  @"http://img.omdbapi.com/?apikey=63af09f9&";

static NSString* kTitle = @"t";
static NSString* kIMDbID = @"i";
static NSString* kYear = @"y";

static NSString* kPosterIMDBiD = @"i";
static NSString* kPosterHeight = @"h";

static NSString* kScrollingUpAnimation = @"UA";
static NSString* kScrollingDownAnimation = @"DA";




@interface ViewController ()
{
    NSDictionary *singleIMDBMovieData;
    NSDictionary *searchingMovieData;
    
    UITableView *mainTableView;
    JDMTableViewCell *jdmCell;
    
    dispatch_queue_t myQueue;
    
    NSMutableArray * searchingResults;
    
    NSMutableArray * initialData;
    NSMutableArray *filteredArray;
    NSArray *sortedArray;
    NSMutableArray *alphabetsArray;
    
    NSMutableArray *sectionTitles;
    NSMutableArray *cellsForEachSection;
    NSString *imdbIDString;
    
    UIScrollView *myScrollView;
    
    BOOL isSearching;
    
    UISearchBar *mySearchBar;
    
    AFHTTPRequestOperationManager *manager;
    
    UIImageView *posterView;
    NSString *searchString;
    
    BOOL isMoving;
    
    CATransform3D baseTransform;
    CALayer *posterCopyLayer;
    UIImageView *posterCopyView;
    
    int checkerToReset;
    
    BOOL goingUp;
    
    NSMutableDictionary *localCache;
    NSMutableArray *localhistory;
    
    UIView *statusBarView;
    
    UIColor *cellTextColor;
    UIImageView *backingImageView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    isSearching = NO;
    [self setupWebStuff];
    [self setupData];
    searchingResults = [[NSMutableArray alloc]init];
    searchString = @"Mallrats";
    
    myQueue = dispatch_queue_create("myQueue", NULL);
    goingUp = NO;
    [self setupLocalCache];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tweaksDismissed) name:@"FBTweakShakeViewControllerDidDismissNotification" object:nil];
 
    
}


-(void)makeSomething
{
    CGFloat amount = 512;
    
    UIView *dummyView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, amount, amount)];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, amount, amount);
    gradient.colors = [NSArray arrayWithObjects:(id)([UIColor colorWithRed:0.000 green:0.725 blue:1.000 alpha:1.000].CGColor),(id)([UIColor colorWithRed:0.376 green:0.471 blue:1.000 alpha:1.000].CGColor),(id)([UIColor colorWithRed:0.514 green:0.573 blue:1.000 alpha:1.000].CGColor),(id)([UIColor colorWithRed:0.439 green:0.576 blue:1.000 alpha:1.000].CGColor),(id)([UIColor colorWithRed:0.592 green:0.525 blue:1.000 alpha:1.000].CGColor),(id)([UIColor colorWithRed:0.459 green:0.251 blue:1.000 alpha:1.000].CGColor),nil];
    gradient.startPoint = CGPointMake(1.0,0);
    gradient.endPoint = CGPointMake(0.00,1.00);
    
    [dummyView.layer insertSublayer:gradient atIndex:0];
    
    
    UIGraphicsBeginImageContextWithOptions(dummyView.bounds.size, NO, 0);
    
    [dummyView drawViewHierarchyInRect:dummyView.bounds afterScreenUpdates:YES];
    
    // UIImage *copied = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    
//   UIView *snapshotView =  [self.view snapshotViewAfterScreenUpdates:YES];
//    
//    UIView *drawn = [self.view  drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];

    
    
    
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}


#pragma mark - SAVING DATA

-(void)saveData
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:localCache];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"localCache"];
    
}

-(NSMutableDictionary*)lookupLocalCache
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"localCache"];
    NSMutableDictionary *localCache_lookedUp = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSLog(@"localCache_lookedUp:%@",localCache_lookedUp);
    
    return localCache_lookedUp;
}


//-(void)generatingRamdomBytes
//{
//    NSUInteger length = 1024*8;
//    
//    //length = 41789;
//    
//    NSMutableData *mutableData =[NSMutableData dataWithLength:length];
//    
//    // OSStatus success = SecRandomCopyBytes(kSecRandomDefault,length,mutableData.mutableBytes);
//    
//    
//
//    
//    
//    
//}



-(UIImageView*)makeBackingBlur
{
    UIImageView *backingBlurView = [[UIImageView alloc]initWithFrame:self.view.frame];
    UIImage *image = [UIImage imageNamed:@"missingCover"];
    UIImage *blurredImage = [image applyLightEffect];
    backingBlurView.image = blurredImage;
    return backingBlurView;
}








#pragma mark - TWEAKS Dismissed

-(void)tweaksDismissed
{
    
    // usuall call setNeedsDisplay, like a refresh.
    // [mySearchBar.layer addAnimation:[self makeSearchBarAnimation] forKey:@"searchBarAnimation"];
    
}









-(void)setupData
{
    [self corrected];
}


- (UIImage *)transparentImage{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0,1.0);
    UIColor *color = [UIColor clearColor];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}




- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, ScreenWidth()*0.75, ScreenHeight()*0.75);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


-(void)constructTableView
{
    
    CGFloat plusY = 150;
    CGRect tvFrame = CGRectMake(0,  64+plusY, self.view.frame.size.width, self.view.frame.size.height);
    UITableView *tableView = [[UITableView alloc]initWithFrame:tvFrame];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.backgroundColor = [UIColor clearColor];
    [tableView registerClass:[JDMTableViewCell class] forCellReuseIdentifier:kCell];
    
    CGRect imageViewRect = CGRectMake(0, 64.0, self.view.frame.size.width, self.view.frame.size.width);
    posterView = [[UIImageView alloc]initWithFrame:imageViewRect];
    posterView.contentMode = UIViewContentModeScaleAspectFit;
    posterView.userInteractionEnabled = YES;
    
    posterCopyView = [[UIImageView alloc]initWithFrame:imageViewRect];
    posterCopyView.contentMode = UIViewContentModeScaleAspectFit;
    posterCopyView.userInteractionEnabled = YES;

    
//    UIPanGestureRecognizer *posterPanGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePosterPan:)];
//    [posterView addGestureRecognizer:posterPanGesture];

    UIImage *baseImage = [self imageWithColor:[UIColor plumColor]];
    posterView.image = baseImage;
    posterView.layer.cornerRadius = 20.0;
    [posterView.layer setMasksToBounds:YES];
    
    posterCopyView.image = baseImage;
    posterCopyView.layer.cornerRadius = 20.0;
    [posterCopyView.layer setMasksToBounds:YES];
    
    UIColor *redAppTintColor = [UIColor colorWithRed:255/255.0f green:103/255.0f blue:136/255.0f alpha:1.0];
       
    tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    tableView.sectionIndexColor = redAppTintColor;

    ///
    statusBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth(), 20)];
    statusBarView.backgroundColor = [UIColor clearColor];

    // BACKING VIEW
    backingImageView = [self makeBackingBlur];

    UISearchBar *searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 20, ScreenWidth(), 44)];
    
    searchBar.placeholder = @"Search Here";
    searchBar.tintColor = [UIColor blackColor];
    searchBar.delegate = self;
    //searchBar.barTintColor = [UIColor ];
    searchBar.backgroundImage = [self transparentImage];
    searchBar.scopeBarBackgroundImage = [self transparentImage];
    
    
    mySearchBar = searchBar;
    mainTableView = tableView;
    
    //////////////////////
    
    [mainTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    [self.view addSubview:statusBarView];
    [self.view addSubview:posterView];
    [self.view addSubview:posterCopyView];
    [self.view addSubview:mainTableView];
    [self.view addSubview:mySearchBar];
    
    [self.view insertSubview:backingImageView atIndex:0];
    
    /* LAYER PREPERATION */
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 1.0 / -1000.0;
    CATransform3D scaleTransform = CATransform3DScale(transform, 1.5, 1.5, 0);
    
    // CATransform3D zoomedTransform = CATransform3DTranslate(transform, 0.0, 60, -50);
    
    CATransform3D zoomedTransform = CATransform3DTranslate(transform, 0.0, 90, -50);
    CATransform3D trans = CATransform3DConcat(scaleTransform, zoomedTransform);
    baseTransform = trans;
    
    backingImageView.layer.zPosition = -500.0;
    
    posterView.layer.transform = trans;
    posterView.layer.speed = 0.0;
    posterView.layer.zPosition = -10.0;
    
    posterCopyView.layer.transform = trans;
    posterCopyView.layer.speed = 0.0;
    posterCopyView.layer.zPosition = -10.0;
    
    mySearchBar.layer.speed=0;
    mySearchBar.layer.zPosition = -1.0;
    
    [posterView.layer addAnimation:[self makeScrollDownAnimation] forKey:kScrollingDownAnimation];
    [posterCopyView.layer addAnimation:[self makeScrollUpAnimation] forKey:kScrollingUpAnimation];
    [mySearchBar.layer addAnimation:[self makeSearchBarAnimation] forKey:@"searchBarAnimations"];
    
}





#pragma mark - UI Handling
#pragma mark - Pan Gesture
// Not using

//-(void)handlePosterPan:(UIPanGestureRecognizer*)posterPan
//{
//    CGPoint panPoint = [posterPan translationInView:posterView];
//    //  CGFloat val = fabs(panPoint.y);
//}
//


#pragma mark - SRCROLL VIEW SCROLLING

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = scrollView.contentOffset.y;
    
    if (offset <= 0 ) {
        
        // SCROLLING DOWN
        // PULLING DOWN
        
        goingUp = NO;
        [self checkAnimations];
        
        CGFloat startLoadingThreshold = 180;
        CGFloat fractionDragged       = -offset/startLoadingThreshold;
        
        CGFloat amount = MAX(0.0, fractionDragged);
        posterView.layer.timeOffset = amount;
        
        mySearchBar.alpha = 1.0;
        mySearchBar.layer.timeOffset = 0.0;
        
        if (fractionDragged >= 1.0) {
            NSLog(@"hit max!");
        }
    }
    else
    {
        
        // SCROLLING UP
        // PULLING UP
        
        // make transform go away
        
        CGFloat searchBarScrollThreshold =  120;
        
        
        if (offset <= searchBarScrollThreshold) {
            CGFloat searchBarfractionDragged = offset/searchBarScrollThreshold;
            mySearchBar.alpha = 1.0;
            mySearchBar.layer.timeOffset =  MAX(0.0, searchBarfractionDragged);
        }
        else
        {
            
            if (!isSearching) {
                mySearchBar.alpha = 0.0;
                mySearchBar.layer.timeOffset = 1.0;

            }
            
        }
        
        goingUp = YES;
        [self checkAnimations];
        
        CGFloat startLoadingThreshold =  mainTableView.contentSize.height  -  (mainTableView.contentSize.height *0.10);
        CGFloat fractionDragged       = offset/startLoadingThreshold;
        CGFloat amountScrolledUp = MAX(0.0, fractionDragged);
        
        posterCopyView.layer.timeOffset = amountScrolledUp;
        
    }
    
    isMoving = YES;
}



-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{

}




-(void)checkAnimations
{
    
    if (goingUp) {
        posterCopyView.alpha = 1.0;
        posterView.alpha = 0.0;
    }
    else
    {
        posterView.alpha = 1.0;
        posterCopyView.alpha = 0.0;
    }
    
}







#pragma mark - LAYER ANIMATIONS

-(CAAnimationGroup *)makeScrollDownAnimation
{
    
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 1.0 / -1000.0;
    
    CATransform3D  backTr = CATransform3DTranslate(transform, 0.0, 60, -300.0);
    
    CATransform3D rotTr = CATransform3DRotate(transform, RadiansFromDegrees(-22.5), 1.0, 0.0, 0.0);
    
    transform = CATransform3DConcat(backTr, rotTr);
    
    CABasicAnimation *transformZAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformZAnimation.fromValue = [NSValue valueWithCATransform3D:baseTransform];
    transformZAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(backTr, rotTr)];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 1.0;
    group.animations = @[transformZAnimation];
    
    group.removedOnCompletion = NO;
    group.autoreverses = YES;
    
    group.repeatCount = MAXFLOAT;
    
    return group;
}


-(CAAnimationGroup *)makeScrollUpAnimation
{
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 1.0 / -1000.0;
    
    CATransform3D  moveImageUpTransform = CATransform3DTranslate(transform, 0.0,  -ScreenHeight()*0.57, -50.0);
    
    CATransform3D zoomInTransform = CATransform3DScale(transform, 1.85, 1.85, 0.0);
    
    CATransform3D  toTransform = CATransform3DConcat(zoomInTransform, moveImageUpTransform);
    
    
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    
    transformAnimation.toValue = [NSValue valueWithCATransform3D:toTransform];
    transformAnimation.fromValue = [NSValue valueWithCATransform3D:baseTransform];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 1.0;
    group.animations = @[transformAnimation];
    
    group.removedOnCompletion = NO;
    group.repeatCount = MAXFLOAT;
    group.autoreverses = YES;
    
    return group;
}


/* SEAERCH BAR ANIMATIONS */

-(CAAnimationGroup *)makeSearchBarAnimation
{
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 1.0 / -1000.0;
    
    
    // CGFloat yTranslation = FBTweakValue(@"Animations", @"SearchBar", @"Y Translation",-16.0, -44.0,44.0);
    // CGFloat zTranslation = FBTweakValue(@"Animations", @"SearchBar", @"Z Translation0",-60.0, -120.0,120.0);
    
    CATransform3D  moveImageUpTransform = CATransform3DTranslate(transform, 0.0,-21,-5.0 );
    
    CATransform3D rotTr = CATransform3DRotate(transform, RadiansFromDegrees(-90), 1.0, 0.0, 0.0);
    
    
    
    CATransform3D  toTransform = CATransform3DConcat(rotTr, moveImageUpTransform);
    
    
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    
    transformAnimation.toValue = [NSValue valueWithCATransform3D:toTransform];
    transformAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 1.0;
    group.animations = @[transformAnimation];
    
    group.removedOnCompletion = NO;
    group.repeatCount = MAXFLOAT;
    group.autoreverses = YES;
    
    return group;
}









#pragma mark - TableView Animations



-(void)repositionTableView:(BOOL)up
{
    CGRect oldFrame;
    CGRect newFrame;
    CGFloat tvTop = mySearchBar.frame.origin.y+mySearchBar.frame.size.height;
    
    if (up) {
        oldFrame=mainTableView.frame;
        newFrame = CGRectMake(oldFrame.origin.x, tvTop+150, oldFrame.size.width, oldFrame.size.height);
    }
    else
    {
        oldFrame=mainTableView.frame;
        newFrame = CGRectMake(oldFrame.origin.x, tvTop, oldFrame.size.width, oldFrame.size.height);
    }
    
    
    [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.25 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        //
        mainTableView.frame = newFrame;
    } completion:^(BOOL finished) {
        //
    }];
    
}






-(void)fadeOutTableView
{
    [UIView animateWithDuration:0.5 animations:^{
        mainTableView.alpha = 0;
        statusBarView.backgroundColor = [UIColor whiteColor];

    } completion:^(BOOL finished) {
        if (finished) {
            // bring up the history tv
        }
    }];
    
}

-(void)fadeInTableView
{
    [UIView animateWithDuration:0.5 animations:^{
        mainTableView.alpha = 1.0;
    }];
}


#pragma mark - Table View

#pragma mark - TableView Data Source
#pragma mark - Sections

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
      
    if (isSearching == YES) {
       
        return  searchingResults.count;
    } else {
       return sectionTitles.count;
    }

}

#pragma mark - TableView Delegate


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JDMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCell];
    if(!cell) {
        cell = [[JDMTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCell];
    }
    

    if (isSearching == YES)
    {
        NSArray *cells = [searchingResults objectAtIndex:indexPath.section];
        NSString *text = [cells objectAtIndex:indexPath.row];
        cell.textLabel.text = text;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.backgroundColor = [UIColor clearColor];
        //cell.textLabel.textColor = cellTextColor;
    }
    else
    {
        NSArray *cells = [cellsForEachSection objectAtIndex:indexPath.section];
        NSString *text = [cells objectAtIndex:indexPath.row];
        cell.textLabel.text = text;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.textColor = [UIColor blackColor];

    }

    return cell;
}



#pragma mark - Header Height
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        
        return 30;
    }
    else
    {
        return 30;
    }

}

#pragma mark - FOOTER Height
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == sectionTitles.count-1) {
        
        return 250;
    }
    else
    {
        return 0;
    }
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    
    if (isSearching) {
        view.backgroundColor = [UIColor whiteColor];
        view.alpha = 0.7;
    }
    
    
   
}



#pragma mark - HEADER TITLES
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (isSearching) {
        
        if (section == 0) {
             return @"Search Results...";
        }
        else
        {
            return @"History";
        }
    }
    else
    {
        return [sectionTitles objectAtIndex:section];
    }
    
    

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (isSearching) {
        NSArray *cells = [searchingResults objectAtIndex:section];
        return cells.count;
        // return searchingResults.count;
    }
    else
    {
        NSArray *cells = [cellsForEachSection objectAtIndex:section];
        return cells.count;
    }
  
}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}



//#pragma mark - Refresh
/* NOT CURRENTLY USING */

//- (void)refresh:(UIRefreshControl *)refreshControl {
//    
//    
//    [self reloadWebDataAndTableViewData];
//    
//    [self doLookupWithParams:[self makeParams]];
//    [self handleData:singleIMDBMovieData];
//    
//    [mainTableView reloadData];
//    
//    [refreshControl endRefreshing];
//}

#pragma mark - --
#pragma mark - RELOAD DATA
#pragma mark - --
-(void)reloadDataForTitle:(NSString*)title
{
    
    UIColor *backgroundColor = [[[localCache objectForKey:@"COLORS"] valueForKey:title] valueForKey:@"BACKGROUND"];
    UIColor *primaryColor =  [[[localCache objectForKey:@"COLORS"] valueForKey:title] valueForKey:@"PRIMARY"];
    UIColor *secondaryColor = [[[localCache objectForKey:@"COLORS"] valueForKey:title] valueForKey:@"SECONDARY"];
    UIColor *detailColor  = [[[localCache objectForKey:@"COLORS"] valueForKey:title] valueForKey:@"DETAIL"];
    
    imdbIDString = [[[localCache objectForKey:@"HISTORY"] valueForKey:title] valueForKey:@"IMDBID"];
    sectionTitles = [[[localCache objectForKey:@"HISTORY"] valueForKey:title] valueForKey:@"SECTIONS"];
    cellsForEachSection = [[[localCache objectForKey:@"HISTORY"] valueForKey:title] valueForKey:@"CELLS"];
    
    UIImage *image = [self retrieveImageFromLocalCacheForTitle:title];
    
    UIImage *blurredImage = [image applyLightEffect];
    
    UIColor *textColor = [UIColor blackColor];
    
    if (detailColor) {
        NSLog(@"detail is nill");
        textColor = detailColor;
    }

    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       backingImageView.image=blurredImage;
                       posterView.image=image;
                       posterCopyView.image=image;
                       
                       
                       mainTableView.sectionIndexColor = secondaryColor;
                       mainTableView.separatorColor = backgroundColor;
                       
                       [self repositionTableView:YES];
                       
                       cellTextColor = secondaryColor;
                       
                       mainTableView.tintColor = primaryColor;
                       //mySearchBar.tintColor = primaryColor;
                       // mySearchBar.backgroundColor = backgroundColor;
                       
                       // statusBarView.backgroundColor = backgroundColor;
                       
                       // mySearchBar.barTintColor = primaryColor;
                       
                       [mainTableView reloadData];
                       
                   });
}


#pragma mark - TableVeiw Delegate
#pragma mark - DID SELECT ROW


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // [self saveData];
    
    
    
    [mySearchBar resignFirstResponder];
     mySearchBar.layer.speed=0.0;
    [mySearchBar.layer addAnimation:[self makeSearchBarAnimation] forKey:@"searchBarAnimations"];
    
    if (isSearching == YES) {
        isSearching = NO;
        searchString = [mainTableView cellForRowAtIndexPath:indexPath].textLabel.text;
        mySearchBar.text = [mainTableView cellForRowAtIndexPath:indexPath].textLabel.text;
        
        if ([self isTitleOnFile:searchString]) {
            // NSLog(@"Already on File, we'll need to look that one up...");
            [self reloadDataForTitle:searchString];
        }
        else
        {
            // check to make sure its a title
            NSLog(@"Nope, lets grab it!");
            
            if (indexPath.section == 0) {
                // NSLog(@"Should be the Search result Box Selected");
                [self corrected];
                //[self performLookupForMovieCover];
            }
            else
            {
                if ([self isTitleOnFile:searchString]) {
                    // NSLog(@"Already on File, we'll need to look that one up...");
                    [self reloadDataForTitle:searchString];
                }
                else
                {
                    // NSLog(@"Nothing ");
                    [self corrected];
                    // [self performLookupForMovieCover];
                }
            }
        }
        
        
        [mainTableView reloadData];
    }
    else
    {
        // [self lookupLocalCache];
    }
    
    

}


#pragma mark UISearchBar Delegate Methods
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
    isSearching = NO;
    
    //isSearching = YES;
    
    searchBar.text = @"";
    mySearchBar.text = @"";
    [searchBar resignFirstResponder];
    [mySearchBar.layer addAnimation:[self makeSearchBarAnimation] forKey:@"searchBarAnimations"];
    
    [self fadeInTableView];
    [mainTableView reloadData];
    [mainTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}


-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    
    isSearching = YES;
    
    [self repositionTableView:NO];
    
    [mySearchBar.layer removeAnimationForKey:@"searchBarAnimations"];
    mySearchBar.layer.speed=1.0;
    mySearchBar.layer.timeOffset = 0.0;
    
    posterView.image = nil;
    posterCopyView.image = nil;
    
    [mainTableView reloadData];
    
   
    return YES;
    
    
}











-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
    
    [mySearchBar resignFirstResponder];
    mySearchBar.layer.speed=0.0;
    [mySearchBar.layer addAnimation:[self makeSearchBarAnimation] forKey:@"searchBarAnimations"];
    
    
    searchString =  searchBar.text;
    isSearching = NO;
    
    
    
    
    if (mainTableView.alpha < 1.0) {
        [self fadeInTableView];
    }
    
    [self corrected];
}



- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    if (mainTableView.alpha < 1.0) {
        [self fadeInTableView];
    }

     mySearchBar.layer.speed=0.0;
    
    return YES;
}


-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if (searchText.length == 0) {
        isSearching = YES;
       
        
        }
    else {
        isSearching = YES;
        
        if (mainTableView.alpha < 1.0) {
            [self fadeInTableView];
        }
    }
//
//        filteredArray = [[NSMutableArray alloc]init];
//        
//        for (NSString * ingredientName in initialData)
//        {
//            NSRange ingredientNameRange = [ingredientName rangeOfString:searchText options:NSCaseInsensitiveSearch];
//            
//            if (ingredientNameRange.location != NSNotFound)
//            {
//                [filteredArray addObject:ingredientName];
//            }
//        }
//        
//    }
    
    
    //change table data
    
    [self searchForMovieTitle:searchText];
    
    [mainTableView reloadData];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    if (isSearching == YES) {
        return nil;
    }
    else
    {
        [self createAlphabetArray];
        return alphabetsArray;

    }
    
}



- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    
    
    for (int i = 0; i < [sectionTitles count]; i++) {
        NSString *letterString = [[sectionTitles objectAtIndex:i] substringToIndex:1];
        if ([letterString isEqualToString:title]) {
            //TODO: Fix o move tot hr right section
            [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        
    }
    return index;
}



#pragma mark - Create Alphabet Array
- (void)createAlphabetArray {
    
    NSMutableArray *tempFirstLetterArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [sectionTitles count]; i++) {
        NSString *letterString = [[sectionTitles objectAtIndex:i] substringToIndex:1];
        if (![tempFirstLetterArray containsObject:letterString]) {
            [tempFirstLetterArray addObject:letterString];
        }
    }
    alphabetsArray = tempFirstLetterArray;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}










#pragma mark - WEB STUFF
-(void)setupWebStuff
{
      manager = [AFHTTPRequestOperationManager manager];
}

-(NSDictionary*)makeParams
{
    NSString *title;
    
    if (searchString) {
        title = searchString;
    }
    else
    {
         title = @"mallrats";
    }
    
    return @{
             kTitle : title,
             @"r":@"json",
             @"tomatoes": @"true",
             
             };
}







// original method
-(void)corrected
{
    [self doLookupWithParams:[self makeParams]];
}



-(void)reloadWebDataAndTableViewData
{
    searchString =  mySearchBar.text;
    isSearching = NO;
    
    [self doLookupWithParams:[self makeParams]];

}



#pragma mark -  NEW IMAGE HERE

-(void)newImageCreated:(UIImage*)image
{
    
    if (isSearching) {
        //
    }
    else
    {
        if (!image) {
            image = [UIImage imageNamed:@"missingCover"];
        }
        
        UIImage *colorlookupImage = image;
        
        colorlookupImage = [colorlookupImage scaledToSize:posterView.frame.size];
        SLColorArt *colorArt = [colorlookupImage colorArt];
        UIColor *backgroundColor = colorArt.backgroundColor;
        UIColor *primaryColor = colorArt.primaryColor;
        UIColor *secondaryColor = colorArt.secondaryColor;
        UIColor *detailColor  = colorArt.detailColor;
        
        NSString *titleString = [self getTitleFromIMDBIDString:imdbIDString];
        
        [self addToLocalCacheColors:@{
                                      @"BACKGROUND" : backgroundColor,
                                      @"PRIMARY" : primaryColor,
                                      @"SECONDARY" : secondaryColor,
                                      @"DETAIL" : detailColor,
                                      } withTitle:titleString];
        
        [self addToLocalCacheImage:image withName:titleString];
        
        
        UIImage *blurredImage = [image applyLightEffect];
        // show image
        
        UIColor *textColor = [UIColor blackColor];
        
        if (detailColor) {
            textColor = detailColor;
        }
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           backingImageView.image = blurredImage;
                           posterView.image=image;
                           posterCopyView.image=image;
                           
                           cellTextColor = secondaryColor;
                           
                           mainTableView.sectionIndexColor = secondaryColor;
                           mainTableView.separatorColor = backgroundColor;
                           
                           [self repositionTableView:YES];
                           
                           mainTableView.tintColor = primaryColor;
                       });

    }
    
    
    
    
    
    

    
    
    
    
}


#pragma mark - Downloading Of Image

-(NSString*)makePosterURLStringWithSize:(NSNumber*)number
{
    NSString *thebase = @"http://img.omdbapi.com/?i=";
    
    NSString *heightString = [NSString stringWithFormat:@"&h=%@",[number stringValue]];
    
    NSString *apiEnd = @"&apikey=63af09f9";
    
    NSString *finalURL = [NSString stringWithFormat:@"%@%@%@%@",thebase,imdbIDString,heightString,apiEnd];
    
    return finalURL;
}

-(void)performLookupForMovieCover
{
       dispatch_async(myQueue, ^{
           
        NSString *posterURL = [self makePosterURLStringWithSize:@(500)];
        
        NSURL *myURL = [NSURL URLWithString:posterURL];
           
        NSData *posterData = [NSData dataWithContentsOfURL:myURL];
        
          NSLog(@" posterData.length:%i",(int) posterData.length);
           
           
        UIImage *posterImage = [UIImage imageWithData:posterData];
           
        [self newImageCreated:posterImage];
    });
}






-(void)doLookupWithParams:(NSDictionary*)parameters
{
    
    //TODO check here
    
    
    
    [manager GET:SiteURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        singleIMDBMovieData = [NSDictionary dictionaryWithDictionary:responseObject];
        [self handleData:[NSDictionary dictionaryWithDictionary:responseObject]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}




// create data for tableview from Movie lookup
-(void)parseData:(NSDictionary*)data
{
    imdbIDString = [data objectForKey:@"imdbID"];
    
    if (imdbIDString) {
        
         [self performLookupForMovieCover];
    }
    
    NSString *titleString = [data objectForKey:@"Title"];
   

    
    sectionTitles = [NSMutableArray arrayWithArray:[data allKeys]];
    
    cellsForEachSection = [[NSMutableArray alloc]init];
    for (NSString* stringOfKey in sectionTitles) {
        
        NSString *dataString = [data objectForKey:stringOfKey];
        NSArray *dataArray = [dataString componentsSeparatedByString:@", "];
        [cellsForEachSection addObject:dataArray];
    }
    
    
    // add to local cache
    [self addToLocalCacheHistoryTitle:titleString withData:
     @{
       @"TITLE" : titleString,
       @"IMDBID" : imdbIDString,
       @"SECTIONS" : sectionTitles,
       @"CELLS" : cellsForEachSection,
       @"DATA" : data,
       }];
    
    [self addToLocalCacheTitle:titleString withIMDBID:imdbIDString];
    
    
    // todo: fix
  
    
    
    
}

-(void)handleData:(NSDictionary*)data
{

    [self parseData:data];
    
    static int checker;
    if (checker==0) {
         [self constructTableView];
    }
    
    [mainTableView reloadData];
    
    checker++;
   
}


// searching
-(void)searchForMovieTitle:(NSString*)searchingString
{
    //implement a local cahcing mechanism to check for values already looked up and load them to the table view,
    
    
  
    if ((int)[searchingString length]<2) {
        
        NSDictionary *data = @{
                                @"Title":@"More letters please...",
                                 };
        
        [self processSearchingData:data];
    }
    else
    {
        //[self performSearch];
        
        // lets check to make sure its not been a string that weve already searched for.
        
        
        
        
        if ([self hasStringAlreadyBeenSearched:searchingString]) {
            
            NSDictionary *createdResponseObject = [self retrieveLocalCacheDataForSearchString:searchingString];
            
            [self processSearchingData:[NSDictionary dictionaryWithDictionary:createdResponseObject]];
            
            [mainTableView reloadData];

            
        }
        else
        {
            
            // new search
            
            NSDictionary *params = @{
                                     @"s"  : searchingString,
                                     @"r"  : @"json",
                                     };
            
                     [manager GET:SiteURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSDictionary *response = [NSDictionary dictionaryWithDictionary:responseObject];
                [self processSearchingData:response];
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
            
           
            

            // searchingResults =  [NSMutableArray arrayWithArray:@[titleContainer,@[],]];

            
            //
            
//            NSDictionary *params = @{kTitle : searchingString,@"r":@"json",};
//            
//            [manager GET:SiteURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                
//                [self addToLocalCacheSearchString:searchingString withData:[NSDictionary dictionaryWithDictionary:responseObject]];
//                
//                searchingMovieData = [NSDictionary dictionaryWithDictionary:responseObject];
//                [self processSearchingData:[NSDictionary dictionaryWithDictionary:responseObject]];
//                
//                [mainTableView reloadData];
//                
//            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                
//            }];
        }
        
        

    }
    
    
    

}


//-(void)performSearch
//{
//    NSDictionary *params = @{
//                             @"s"  : searchString,
//                             @"r":@"json",
//                             };
//    
//    
//    
//    [manager GET:SiteURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        // NSLog(@"responseObject:%@",responseObject);
//        
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//    }];
//    
//}



-(void)processSearchingData:(NSDictionary*)searchData
{
    
    NSLog(@"searchData:%@",searchData);
    
    NSMutableArray *titleContainer = [[NSMutableArray alloc]init];
    
    NSDictionary *searchDictionary = [searchData objectForKey:@"Search"];
    
    
    if (!searchDictionary) {
        NSLog(@"its nil");
        [titleContainer addObject:[searchData valueForKey:[[searchData allKeys] firstObject]]];
    }
    
    for (NSDictionary *searchResult in searchDictionary) {
        
        NSString *titleResult = [searchResult valueForKey:@"Title"];
//        imdbIDString = [searchData valueForKey:@"imdbID"];
//        [self addToLocalCacheTitle:titleResult withIMDBID:imdbIDString];
        [titleContainer addObject:titleResult];
        
    }
    
    searchingResults = [NSMutableArray arrayWithArray:@[titleContainer,[self retrieveListOfTitlesFromLocalCached],]];
    [mainTableView reloadData];

}





#pragma mark - Local Cache

-(void)setupLocalCache
{
    
    localCache = [NSMutableDictionary dictionary];
    [localCache addEntriesFromDictionary:@{
                                           @"HISTORY" : [NSMutableDictionary dictionary],
                                           @"IMAGES" : [NSMutableDictionary dictionary],
                                           @"IMDB_ID" : [NSMutableDictionary dictionary],
                                           @"TITLE" : [NSMutableDictionary dictionary],
                                           @"COLORS" : [NSMutableDictionary dictionary],
                                           @"LOCAL_HISTORY" : [NSMutableArray array],
                                           @"SEARCH_HISTORY" : [NSMutableDictionary dictionary],
                                           }];
    
    localhistory = [[NSMutableArray alloc]init];
    
}

-(void)addToLocalCacheImage:(UIImage*)image withName:(NSString*)name
{
    [[localCache objectForKey:@"IMAGES"] addEntriesFromDictionary:@{name:image}];
}

-(UIImage*)retrieveImageFromLocalCacheForTitle:(NSString*)title
{
    return [[localCache objectForKey:@"IMAGES"] valueForKey:title];
}


-(void)addToLocalCacheTitle:(NSString*)title withIMDBID:(NSString*)iMDBIDstring
{
    [[localCache objectForKey:@"IMDB_ID"] addEntriesFromDictionary:@{title:iMDBIDstring}];
    [[localCache objectForKey:@"TITLE"] addEntriesFromDictionary:@{iMDBIDstring:title}];
    
    [[localCache objectForKey:@"LOCAL_HISTORY"] addObject:title];
}

-(void)addToLocalCacheHistoryTitle:(NSString*)title withData:(NSDictionary*)data
{
    [[localCache objectForKey:@"HISTORY"] addEntriesFromDictionary:@{title:data}];
}

-(NSArray*)retrieveListOfTitlesFromLocalCached
{
    NSMutableArray *cachedTitles = [[NSMutableArray alloc]init];
    
    for (NSString* stringVar in [[localCache objectForKey:@"HISTORY"] allKeys]) {
        [cachedTitles addObject:[[[localCache objectForKey:@"HISTORY"] valueForKey:stringVar] valueForKey:@"TITLE"]];
    }
    
    return cachedTitles;
}

-(NSDictionary*)retrieveDataFromLocalCacheForTitle:(NSString*)title
{
    return [[[localCache objectForKey:@"HISTORY"] valueForKey:title] valueForKey:@"DATA"];
}


-(void)addToLocalCacheColors:(NSDictionary*)colors withTitle:(NSString*)title
{
    [[localCache objectForKey:@"COLORS"] addEntriesFromDictionary:@{title:colors}];
}

//
-(void)addToLocalCacheSearchString:(NSString*)string withData:(NSDictionary*)data
{
    [[localCache objectForKey:@"SEARCH_HISTORY"] addEntriesFromDictionary:@{string:data}];
}

-(NSArray*)listOfPreviousSearchStrings
{
    return [[localCache objectForKey:@"SEARCH_HISTORY"] allKeys];
}

-(BOOL)hasStringAlreadyBeenSearched:(NSString*)string
{
    BOOL hasTermBeenSearched = NO;
    
    NSArray *stringsAlreadyUsed = [self listOfPreviousSearchStrings];
    
    for (NSString *usedString in stringsAlreadyUsed) {
        if ([string isEqualToString:usedString]) {
            hasTermBeenSearched = YES;
        }
    }
    
    return hasTermBeenSearched;
}


-(BOOL)isTitleOnFile:(NSString*)title
{
    BOOL isTitleOnFile = NO;
    
    NSArray *titles = [self retrieveListOfTitlesFromLocalCached];
    
    for (NSString *onFileTitle in titles) {
        if ([onFileTitle isEqualToString:title]) {
            isTitleOnFile = YES;
        }
    }
    
    return isTitleOnFile;
}

-(NSDictionary*)retrieveLocalCacheDataForSearchString:(NSString*)string
{
    return [[localCache objectForKey:@"SEARCH_HISTORY"] objectForKey:string];
}


-(NSString*)getTitleFromIMDBIDString:(NSString*)iMDBIDString
{
    return [[localCache objectForKey:@"TITLE"] objectForKey:iMDBIDString];
}

-(NSArray*)allCurrentlyFoundTitles
{
    return [[localCache objectForKey:@"IMDB_ID"] allKeys];
}




@end
