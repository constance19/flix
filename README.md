# Project 2 - flix

flix is a movies app using the [The Movie Database API](http://docs.themoviedb.apiary.io/#).

Time spent: 19 hours spent in total

## User Stories

The following **required** functionality is complete:

- [x] User sees an app icon on the home screen and a styled launch screen.
- [x] User can view a list of movies currently playing in theaters from The Movie Database.
- [x] Poster images are loaded using the UIImageView category in the AFNetworking library.
- [x] User sees a loading state while waiting for the movies API.
- [x] User can pull to refresh the movie list.
- [x] User sees an error message when there's a networking error.
- [x] User can tap a tab bar button to view a grid layout of Movie Posters using a CollectionView.

The following **optional** features are implemented:

- [x] User can tap a poster in the collection view to see a detail screen of that movie
- [x] User can search for a movie.
- [x] All images fade in as they are loading.
- [x] User can view the large movie poster by tapping on a cell.
- [x] For the large poster, load the low resolution image first and then switch to the high resolution image when complete.
- [x] Customize the selection effect of the cell.
- [x] Customize the navigation bar.
- [x] Customize the UI.
- [ ] User can view the app on various device sizes and orientations.
- [ ] Run your app on a real device.

The following **additional** features are implemented:

- [x] Customize the tab bar.

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

1. How to use constraints to customize the spacing and font size on the detailed view page of a movie, based on the length of its title and synopsis.

2. How to allow the user to view the app on various device sizes and orientations.

## Video Walkthrough

Here's a walkthrough of implemented user stories:

Table view for movie display:
![flix table view](flix_table_compress.gif) / ! [](flix_table_compress.gif)

Grid view for movie display:
![flix grid view](flix_grid_compress.gif) / ! [](flix_grid_compress.gif)

Loading state (activity indicator for poor internet):
![flix loading state](flix_loading_state.gif) / ! [](flix_loading_state.gif)

Network error (no internet alert message, reconnection):
![flix network error](flix_network_error.gif) / ! [](flix_network_error.gif)

GIF created with [ezgif](https://ezgif.com/video-to-gif).

## Notes

Describe any challenges encountered while building the app.
I ran into issues with the activity indicator, specifically in terms of resizing, recoloring, and moving it on the view controller. I also was unable to completely figure out how to use constraints, which prevented me from significantly improving the visual aesthetic of the detailed view page.


## Credits

List an 3rd party libraries, icons, graphics, or other assets you used in your app.

- [AFNetworking](https://github.com/AFNetworking/AFNetworking) - networking task library
- [IconBeast] (http://www.iconbeast.com/) - tab bar icon library
- [IconArchive] (https://iconarchive.com/) - launch screen app logo

## License

    Copyright [2021] [Constance Horng]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
