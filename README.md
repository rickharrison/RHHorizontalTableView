# RHHorizontalTableView 0.1.0

RHHorizontalTableView is a subclass of `UITableView`, which is a part of `UIKit`. Instead of scrolling vertically, it scrolls horizontally and loads in new cells as they come onto the screen from the left or right.

# Guidelines

Before implementation, make sure you understand the following:

1. The height of the rows will be what you set as the height property for the table view
2. Section headers will appear in the top left of the table view with the width and height as returned by the delegate methods. Instead of being pushed off the screen, subsequent section headers will scroll over top of other headers.
3. You can either have the scroll bar be at the top or the bottom of the table view using the `indicatorPosition` property. Possible values are:
    - `RHHorizontalTableViewScrollIndicatorPositionTop`
    - `RHHorizontalTableViewScrollIndicatorPositionBottom`

# Usage

1. Clone or otherwise copy `RHHorizontalTableView.h` and `RHHorizontalTableView.m` into your project.
2. Create a `RHHorizontalTableView` either in Interface Builder or in code with `- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style`
3. Implement the data source/delegate methods as you would usually with one caveat:
    - Return the desired **width** of a cell in `- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath`

# To Do

1. Support `UITableViewStyleGrouped`
2. Allow section headers to push previous headers off the screen as in the vertical version

# License

Copyright (c) 2011 Rick Harrison, http://rickharrison.me

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.