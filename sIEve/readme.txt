IEÄÚ´æÐ¹Â¶¼à²â¹¤¾ß

http://home.orange.nl/jsrosman/


sIEve

sIEve is a project to get rid of memory leaks due to some limitations of the garbage collector in Internet Explorer. Executing AJAX kind of applications (like Cordys Explorer) will stress the browser heavily. Internet Explorer is not very strong in Memory Management. With other words; It is very easy to introduce serious memory leaks in Internet Explorer by executing JavaScript and DHTML manipulation.
Main Dialog

Back: Going back in browser history (not yet tested)

previous: Going forward in browser history (not yet tested)

Adress: The URL to Navigate (Last visited URL will be kept in Registry and will be restored when you restart sIEve

GO: Navigate to the URL in Address field. (Also the default button if you press 'Enter')

about:blank: unloads the current page. giving a blank screen. This is extremely usefull to find leaks after page is unloaded. If you press the Show in Use button after pressing the about:blank button then you see all the real leaks (DOM elements which are not freed or garbage collected by IE.

IE Browser control: In this area the webpage¡¯s will be loaded and shown.

Auto Refresh: The current URL will be automatically refreshed. In the memory samples list and graph you can observe if there are still leaks in your application. The ¡®Auto Refresh¡¯ button will change into ¡®Stop¡¯ to cancel the auto refesh mode.

Clear in use: The current list of registered DOM elements in use will be cleared. Actually the Items will be hidden from the ¡®Elements in Use¡¯ Dialog.

Show in use: A (modeless) dialog will be opened to show all DOM elements currently in use. If the dialog was already open the list on the dialog will be refreshed. Elements which are cleared from the list by usage of the ¡®Clear in Use¡¯ button will not be showed again unless there is an increase in the number of references to the particular hidden elements. (IE when the elements refcounter is increased, in fact it is a new element in use which can cause a leak. The Dialog Stays open so you can press again and again the ¡®Show In use¡¯ button. The dialog also contains the same ¡®Clear inUse / show in use / show leaks¡¯ buttons. The buttons on that dialog has the same functionality as their counterparts on the main dialog.

Show Leaks: A (modeless) dialog will be opened to show all known leaks until now. Old leaks will remain on the list and never cleared. However you can distinghish new leaks form old leaks. (Colors and document id¡¯s are used to distinguish)

Memory Samples List: This list will contain the last known (200) memory samples. The VM size (virtual memory) is reported in the list. Pressing the ¡®Go¡¯ button or the ¡®Auto Refresh¡¯ button will clear the memory samples list. Green lines indcates memory reduction; Red lines indicates increase; Black lines indicates no change in memory usage since previous sample.

Usage: Working Set size of physical used memory in Kilobytes (KB)

Delta: Difference in memory usage since previous sample in Kilobytes (KB)

Avg: The average of Delta¡¯s in Kilobytes (KB). Notice that this figure only gives some indication. Big fluctuations in memory usage can give unpredictable results.

#inUse: The actual number of registered DOM Elements by the sIEve tool.

#hidden: The actual number of hidden DOM Elements from the list due to usage of the ¡®Clear in Use¡¯ button

Memory Samples History: A graph showing all values from the ¡®Usage¡¯ column in the memory Samples List. However this graph will never be cleared. (So take care ¡®sIEve¡¯ has a (relative) small memory leak due to the unlimited size of the history.

Slow/Fast/Paused: The update speed of the Memory Samples History Graph and List. Slow = 5 seconds; Fast = 1 Second; Paused = no updates;

Help: Opens new IE Browser window with help information.

Log Defect: Opens new IE Browser window where you can log any issue (Don¡¯t forget to log-in or specify your name, that will be easier for giving feedback by the developers of the tool.

[edit]
Elements in Use / Leaks Dialog

This dialog will be shared for 2 functions: Showing all elements in use and showing all known leaks. The dialog is modeless you can keep it open. Red lines means that the item is new in the list since previous report; Blue lines means that the Element is not new in the list but the reference counter is increased since last report. Green lines means that the element is freed (Refs = 0) (However currently this feature is not used since freed elements will just be removed from the list)

List Control: Showing Elements with a number of properties per element. You can sort the list on any column (except the OuterHTML column is not sortable)

#: Auto generated Sequence number of registered element

doc: Auto generated Sequence number of registered (owner) document of the particular element. This is useful to view and distinguish leaks of several runs of the same URL.

URL: Source url of the element

Refs: Number of references to the DOM Element.

Tag: The DOM node name of the registered DOM Element

ID: The DOM id property value

Orphan: if the value in this column is ¡°Yes¡± then the element is not attached to the document.body. IE then it is a orphan node. In IE this Elements can leak as well so special care should be taken on this kinds of elements. For example clearing/setting the innerHTML of orphan nodes will cause pseudo leaks. Also orphan nodes will not fire ¡®onpropertychange¡¯ events.

Leak: If the element is a know leak then the value in this column is ¡®Yes¡¯. This is only possible in combination with Running Document = ¡°No¡± (the next column)

Running: Indicates if a document is running. As soon a webpage will exit

outerHTML: Showing the outer HTML. (limited to 200 bytes to avoid memory blow up of sIEve)

Address: Currently not used (was used for low level memory allocs, which feature is currently disabled In sIEve)

Size: Currently not used (was used for low level memory allocs, which feature is currently disabled In sIEve)

properties: Opens a new modal dialog showing all the (expando) properties of the DOM element.

Clear in Use: Same as in main dialog

Show in Use: Same as in main dialog

Show Leaks: Same as in main dialog

Copy: Copy list into clipboard

# Items: Number of items showed in the list

New Item: A red line means: First time the items is showed in the list; If you do some actions in the webpage and you press again the ¡®Show in Use¡¯ button then all the existing elements in the list become black and all the new elements in use are reported in red.

No change: A black line means there is no change since previous report

Increased refcount: A blue line means: Item is not new but the reference count to the element in increased since previous report

Decreased refcount: A green line means: Item is not new but the reference count to the element in decreased since previous report

Close: Hide the dialog (can be opened again)