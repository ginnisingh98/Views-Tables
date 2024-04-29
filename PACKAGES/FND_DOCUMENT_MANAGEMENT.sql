--------------------------------------------------------
--  DDL for Package FND_DOCUMENT_MANAGEMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_DOCUMENT_MANAGEMENT" AUTHID CURRENT_USER as
/* $Header: AFWFDMGS.pls 120.8 2006/08/18 15:09:38 blash ship $ */

/*===========================================================================

  PL*SQL TABLE NAME:	fnd_dm_product_parms_type

  DESCRIPTION:		stores the list of parameters for a given function

============================================================================*/

TYPE fnd_dm_product_parms_type IS RECORD
(
   parameter_name        VARCHAR2(80),
   parameter_syntax	 VARCHAR2(240)
);

 TYPE fnd_dm_product_parms_tbl_type IS TABLE OF
    fnd_document_management.fnd_dm_product_parms_type
 INDEX BY BINARY_INTEGER;

/*===========================================================================

  PL*SQL TABLE NAME:	fnd_dm_product_parms_type

  DESCRIPTION:		stores the list of parameters for a given function

============================================================================*/

TYPE fnd_document_attributes IS RECORD
(
   document_identifier VARCHAR2(2000),
   document_name       VARCHAR2(240),
   document_type       VARCHAR2(80),
   filename            VARCHAR2(80),
   created_by          VARCHAR2(80),
   last_updated_by     VARCHAR2(80),
   last_update_date    VARCHAR2(40),
   locked_by           VARCHAR2(80),
   document_size       VARCHAR2(20),
   document_status     VARCHAR2(20),
   current_version     VARCHAR2(10),
   latest_version      VARCHAR2(10)
);

/*===========================================================================
Function	get_search_document_url

Purpose		Bring up a search window to allow the user to find a
                document in their document management system. The function
                does not take a document system argument because you'll
                be first asked to choose which document  management
                system to search before given the actual search criteria.

                The challenge here is to return the DM system id, the
                document id, and the document name for the document that
                you've selected during your search process. We'll likely
                need our DM software partners to add new arguments to their
                standard URL syntax to allow for extra url links/icons that
                refer to Oracle Application functions that will allow us to
                return the selected documents that you wish to attach to your
                application business objects. The extra arguments would be
                pushed into the standard HTML templates so you can execute
                these functions when you've selected the appropriate document.

Parameters

callback    -	The URL you would like to envoke after the
		user has selected the document.

html_formatting - Tells the function whether you want just
		  the URL or the URL with the appropriate
		  icon and prompt name. If you only want
		  the URL then pass FALSE.  If you want
		  the URL with a HTML formatted icon
                  and translated function name then pass TRUE.

display_document_URL - The URL result to search for a specific
                       document

============================================================================*/
PROCEDURE get_search_document_url
(username               IN  Varchar2,
 callback_function 	IN  Varchar2,
 html_formatting 	IN  Boolean,
 search_document_URL 	OUT NOCOPY Varchar2);

/*===========================================================================
Function	get_create_document_url

Purpose		Create a new document in your Document Management System
                for a local file stored on your file system.

                The challenge here is to return the DM system name and the
                document id/name for the document that you've just added to
                the DM system. If your in the attachments form and you've
                attached a file, you may wish to add that file to a DM
                system by clicking on the Create New link. Once you provide
                all the meta data for that document in the DM system we'll
                need to push the document information back to the creating
                application object. We'll likely need our DM software
                partners to add new arguments to their standard URL
                syntax to allow for extra url links/icons that refer to
                Oracle Application functions that will allow us to return
                the selected document id information once you've created
                your document. The extra arguments would be pushed into
                the standard HTML templates so you can execute these
                functions when you've selected the created the document.

Parameters

callback    -	The URL you would like to envoke after the
		user has created in the document.

html_formatting - Tells the function whether you want just
		  the URL or the URL with the appropriate
		  icon and prompt name. If you only want
		  the URL then pass FALSE.  If you want
		  the URL with a HTML formatted icon
                  and translated function name then pass TRUE.

create_document_URL - The URL result to create the selected
		       document on the selected node

============================================================================*/
PROCEDURE get_create_document_url
(username               IN  Varchar2,
 callback_function 	IN  Varchar2,
 html_formatting 	IN  Boolean,
 create_document_URL 	OUT NOCOPY Varchar2);

/*===========================================================================
Function	get_browse_document_url

Purpose		Browse through a folder hierarchy and choose the document
		you wish to attach then return that document to the calling
		application.

                The challenge here is to return the DM system name and the
                document id/name for the document that you've selected in
                the DM system. If your in the attachments form and you've
                attached a file, you may wish to select a file using the
		browse feature. Once you select a  document in the DM
                system we'll need to push the document information
                back to the creating application object. We'll likely
                need our DM software
                partners to add new arguments to their standard URL
                syntax to allow for extra url links/icons that refer to
                Oracle Application functions that will allow us to return
                the selected document id information once you've created
                your document. The extra arguments would be pushed into
                the standard HTML templates so you can execute these
                functions when you've selected the created the document.

============================================================================*/
PROCEDURE get_browse_document_url
(username               IN  Varchar2,
 callback_function 	IN  Varchar2,
 html_formatting 	IN  Boolean,
 browse_document_URL 	OUT NOCOPY Varchar2);

/*===========================================================================
Function	get_display_document_url

Purpose		Invoke the appropriate document viewer for the selected
		document. Most document management systems
		support a wide range of document formats for viewing.
		We will rely on the  document management system to
                display the document in it's native format whenever possible.

Parameters

document_identifier -	The dm document Identifier from which your going
			display the document.

show_document_icon -	Should the function add an icon along with the
                        document name to represent the document anchor

html_formatting - Tells the function whether you want just
		  the URL or the URL with the appropriate
		  icon and prompt name. If you only want
		  the URL then pass FALSE.  If you want
		  the URL with a HTML formatted icon
                  and translated function name then pass TRUE.

display_document_URL - The URL result to display the selected
		       document from the selected node

============================================================================*/
PROCEDURE get_display_document_url
(username             IN  Varchar2,
 document_identifier  IN  Varchar2,
 show_document_icon   IN Boolean,
 html_formatting      IN Boolean,
 display_document_URL OUT NOCOPY Varchar2);

/*===========================================================================
Function	get_original_document_url

Purpose		Invoke the appropriate document viewer for the latest version
                of the selected document. The default operation of the DM
                system is to show the version that was attached to the item.
                We are providing another function here to show the most
                recent version of the document.
                Most document management systems
		support a wide range of document formats for viewing.
		We will rely on the  document management system to
                display the document in it's native format whenever possible.

Parameters

document_identifier -	The dm document Identifier from which your going
			display the document.

show_document_icon -	Should the function add an icon along with the
                        document name to represent the document anchor

html_formatting - Tells the function whether you want just
		  the URL or the URL with the appropriate
		  icon and prompt name. If you only want
		  the URL then pass FALSE.  If you want
		  the URL with a HTML formatted icon
                  and translated function name then pass TRUE.

original_document_URL - The URL result to display the selected
		       document from the selected node

============================================================================*/
PROCEDURE get_original_document_url
(username             IN  Varchar2,
 document_identifier  IN  Varchar2,
 show_document_icon   IN Boolean,
 html_formatting      IN Boolean,
 original_document_URL OUT NOCOPY Varchar2);

/*===========================================================================
Function	get_fetch_document_url

Purpose		Fetch a copy of a document from a document management system
                and place it on the local system.

Parameters

document_identifier -	The dm document Identifier from which your going
			display the document.

html_formatting - Tells the function whether you want just
		  the URL or the URL with the appropriate
		  icon and prompt name. If you only want
		  the URL then pass FALSE.  If you want
		  the URL with a HTML formatted icon
                  and translated function name then pass TRUE.

fetch_document_URL - The URL result to fetch the selected
		       document from the selected node

============================================================================*/
PROCEDURE get_fetch_document_url
(username               IN  Varchar2,
 document_identifier    IN  Varchar2,
 html_formatting 	IN  Boolean,
 fetch_document_URL 	OUT NOCOPY Varchar2);

/*===========================================================================
Function	get_check_out_document_url

Purpose		Lock the document in the DM system so that no other user can
                check in a new revision of the document while you
                hold the lock. This function will also allow you to create
                a local copy of the document on your file system.

Parameters

document_identifier -	The dm document Identifier from which your going
			display the document.

html_formatting - Tells the function whether you want just
		  the URL or the URL with the appropriate
		  icon and prompt name. If you only want
		  the URL then pass FALSE.  If you want
		  the URL with a HTML formatted icon
                  and translated function name then pass TRUE.

check_out_document_URL - The URL result to check out the selected
		       document from the selected node

============================================================================*/
PROCEDURE get_check_out_document_url
(username               IN  Varchar2,
 document_identifier    IN  Varchar2,
 html_formatting 	IN  Boolean,
 check_out_document_URL OUT NOCOPY Varchar2);

/*===========================================================================
Function	get_check_in_document_url

Purpose		Copy a new version of a file from your local file system
                back into the document management system.  UnLock the
                document in the DM system so that other users can work
                on the document.

Parameters

document_identifier -	The dm document Identifier from which your going
			display the document.

html_formatting - Tells the function whether you want just
		  the URL or the URL with the appropriate
		  icon and prompt name. If you only want
		  the URL then pass FALSE.  If you want
		  the URL with a HTML formatted icon
                  and translated function name then pass TRUE.

check_in_document_URL - The URL result to check in the selected
		       document from the selected node

============================================================================*/
PROCEDURE get_check_in_document_url
(username               IN Varchar2,
document_identifier     IN  Varchar2,
html_formatting 	IN  Boolean,
check_in_document_URL 	OUT NOCOPY Varchar2);


/*===========================================================================
Function	get_lock_document_url

Purpose		Lock the document in the DM system so that no other
                user can check in a new revision of the document while
                you hold the lock.

Parameters

document_identifier -	The dm document Identifier from which your going
			display the document.

html_formatting - Tells the function whether you want just
		  the URL or the URL with the appropriate
		  icon and prompt name. If you only want
		  the URL then pass FALSE.  If you want
		  the URL with a HTML formatted icon
                  and translated function name then pass TRUE.

lock_document_URL - The URL result to lock the selected
		       document from the selected node

============================================================================*/
PROCEDURE get_lock_document_url
(username               IN  Varchar2,
 document_identifier    IN  Varchar2,
 html_formatting 	IN  Boolean,
 lock_document_URL 	OUT NOCOPY Varchar2);

/*===========================================================================
Function	get_unlock_document_url

Purpose		Unlock the document in the DM system without checking
                in a new version of the document so that other users
                can check in new revisions of the document.

Parameters

document_identifier -	The dm document Identifier from which your going
			display the document.

html_formatting - Tells the function whether you want just
		  the URL or the URL with the appropriate
		  icon and prompt name. If you only want
		  the URL then pass FALSE.  If you want
		  the URL with a HTML formatted icon
                  and translated function name then pass TRUE.

unlock_document_URL - The URL result to unlock the selected
		       document from the selected node

============================================================================*/
PROCEDURE get_unlock_document_url
(username               IN  Varchar2,
 document_identifier    IN  Varchar2,
 html_formatting 	IN  Boolean,
 unlock_document_URL 	OUT NOCOPY Varchar2);

/*===========================================================================
Function	get_display_history_url

Purpose		Display the file history for the document in the Document
                Management System. Display the document title, type, size,
                whether the document is locked and if so by who, who has
                edited the document and when, etc.

Parameters

document_identifier -	The dm document Identifier from which your going
			display the document.

html_formatting - Tells the function whether you want just
		  the URL or the URL with the appropriate
		  icon and prompt name. If you only want
		  the URL then pass FALSE.  If you want
		  the URL with a HTML formatted icon
                  and translated function name then pass TRUE.

unlock_document_URL - The URL result to unlock the selected
		       document from the selected node

============================================================================*/
PROCEDURE get_display_history_url
(username               IN  Varchar2,
 document_identifier    IN  Varchar2,
 html_formatting 	IN  Boolean,
 display_history_URL 	OUT NOCOPY Varchar2);

/*===========================================================================

Function	get_launch_document_url

Purpose		Set up the anchor to launch a new window with a frameset
                with two frames.  The upper frame has all the controls.
                The lower frame displays the document.

============================================================================*/
PROCEDURE get_launch_document_url
(username               IN  Varchar2,
 document_identifier  IN  Varchar2,
 display_icon         IN  Boolean,
 launch_document_URL OUT NOCOPY Varchar2);

/*===========================================================================

Function	create_display_document_url

Purpose		Launches the toolbar in one frame for the document
                operations and then creates another frame to display
                the document.

============================================================================*/
PROCEDURE create_display_document_url
(username             IN  Varchar2,
 document_identifier  IN  Varchar2);

/*===========================================================================

Function	get_open_dm_display_window

Purpose		Get the javascript function to open a dm window based on
                a url and a window size.  This java script function will
                be used by all the DM display functions to open the
                appropriate DM window.  This function also gives the
                current window a name so that the dm window can call
                back to the javascript functions in the current window.

Parameters

============================================================================*/
PROCEDURE get_open_dm_display_window;

/*===========================================================================

Function	get_open_dm_attach_window

Purpose		Get the javascript function to open a dm window based on
                a url and a window size.  This java script function will
                be used by all the DM functions to open the appropriate DM
                window when attaching a new document to a business object.
                This function also gives the current window
                a name so that the dm window can call back to the javascript
                functions in the current window.

Parameters

============================================================================*/
PROCEDURE get_open_dm_attach_window;

/*===========================================================================

Function	set_document_id_html

Purpose		Get the javascript function to set the appropriate
                destination field on your html form from the document
                management select function.

Parameters

function_name - The name of the javascript function.  This naming allows
		you to have multiple document fields on the same page.

frame_name  -	The name of the html frame for the current ui that you
                wish to interact with

form_name  -	The name of the html form for the current ui that you
                wish to interact with

document_id_field_name  -
		The name of the html field that you would like to write
		the resulting document identifier to:
	        Document identifier is the concatention of the following
                values:

                nodeid:documentid:version:document_name

document_name_field_name  -
		The name of the html field that you would like to write
		the resulting document name to.


============================================================================*/
PROCEDURE set_document_id_html
(
  frame_name  IN VARCHAR2,
  form_name  IN VARCHAR2,
  document_id_field_name IN VARCHAR2,
  document_name_field_name IN VARCHAR2,
  callback_url   OUT NOCOPY VARCHAR2
);

--
-- PackDocInfo
--   Pack together the document components out of a document type
--   attribute.
--
--   dm_node_id -   Id for of the dm system where the document is
--                  maintained
--
--   document_id - Identifier for the document for the particular dm node
--
--   version - Version of Document that was selected
--
--   document_info - Concatenated string of characters that includes the
--                   nodeid, document id, version, and
--                   document name in the following format:
--
--                   nodeid:documentid:version
--
--
procedure PackDocInfo(dm_node_id    in number,
                       document_id   in varchar2,
		       version       in varchar2,
		       document_info out NOCOPY varchar2);

--
-- ParseDocInfo
--   Parse out the document components out of a document type
--   attribute.
--
--   document_info - Concatenated string of characters that includes the
--                   nodeid, document id, version, and
--                   document name in the following format:
--
--                   nodeid:documentid:version
--
--   dm_node_id -   Id for of the dm system where the document is
--                  maintained
--
--   document_id - Identifier for the document for the particular dm node
--
--   version - Version of Document that was selected
--
--
procedure ParseDocInfo(document_info in  varchar2,
                       dm_node_id    out NOCOPY number,
                       document_id   out NOCOPY varchar2,
		       version       out NOCOPY varchar2);

/*===========================================================================

Function	create_document_toolbar

Purpose		create the toolbar for checking in/checking out etc.
                documents based on the document identifier

============================================================================*/
PROCEDURE  create_document_toolbar
(
  username            IN Varchar2,
  document_identifier IN Varchar2
);

/*===========================================================================

Function	get_launch_attach_url

Purpose		Set up the anchor to launch a new window with a frameset
                with two frames.  The upper frame has all the controls.
                The lower frame displays the document.

============================================================================*/
PROCEDURE get_launch_attach_url
(username             IN  Varchar2,
 callback_function    IN  Varchar2,
 display_icon         IN  Boolean,
 launch_attach_URL    OUT NOCOPY Varchar2);


/*===========================================================================

Function	create_display_document_url

Purpose		Launches the toolbar in one frame for the document
                operations and then creates another frame to display
                the document.

============================================================================*/
PROCEDURE create_attach_document_url
(username           IN     Varchar2,
 callback_function  IN     Varchar2);


/*===========================================================================

Function	create_document_toolbar

Purpose		create the toolbar for checking in/checking out etc.
                documents based on the document identifier

============================================================================*/
PROCEDURE  create_attach_toolbar
(
  username          IN  VARCHAR2,
  callback_function IN  VARCHAR2
);

/*===========================================================================

Function	get_dm_home

Purpose		fetch the document management home preference for a given
                user.  If there is no home defined for a user then go
                check the default.  If there is no default defined then
                get the first dm_node in the list.

============================================================================*/
procedure get_dm_home (
username     IN  VARCHAR2,
dm_node_id   OUT NOCOPY VARCHAR2,
dm_node_name OUT NOCOPY VARCHAR2);


/*===========================================================================

Function	set_dm_home

Purpose		set the document management home preference for a given
                user.

============================================================================*/
procedure set_dm_home (
username     IN  VARCHAR2,
dm_node_id   IN  VARCHAR2);

/*===========================================================================

Function	set_dm_home_html

Purpose		set the document management home preference for a given
                user throught the html interface

============================================================================*/
procedure set_dm_home_html (
dm_node_id   IN  VARCHAR2,
username     IN  VARCHAR2,
callback     IN  VARCHAR2);

/*===========================================================================

Function	Dm_Nodes_Display

Purpose		Display the various document management server nodes that the
                administrator has set up as their enterprise document network

============================================================================*/
procedure Dm_Nodes_Display;

/*===========================================================================

Function	Dm_Nodes_edit

Purpose		Edit or add a new node to the enterprise document network

============================================================================*/
procedure Dm_Nodes_Edit (
p_node_id   IN VARCHAR2   DEFAULT NULL
);

/*===========================================================================

Function	Dm_Nodes_Update

Purpose		Execute the update of the attributes for the document management
                node.
============================================================================*/
procedure Dm_Nodes_Update (
p_node_id            IN VARCHAR2   DEFAULT NULL,
p_node_name          IN VARCHAR2   DEFAULT NULL,
p_node_description   IN VARCHAR2   DEFAULT NULL,
p_connect_syntax     IN VARCHAR2   DEFAULT NULL,
p_product_id         IN VARCHAR2   DEFAULT NULL,
p_product_name       IN VARCHAR2   DEFAULT NULL
);

/*===========================================================================

Function	Dm_Nodes_Confirm_Delete

Purpose		Delete a currently defined document management node that
		has been set up by an administrator.  There is no check to
		see if any documents are referencing the document node that
		is about to be deleted.  Deleting a document node that has
		references will produce warnings when you try to view
		documents that use this reference.
============================================================================*/
procedure Dm_Nodes_Confirm_Delete (
p_node_id   IN VARCHAR2   DEFAULT NULL
);

/*===========================================================================

Function	Dm_Nodes_Delete

Purpose		Does the physical delete of a document node after the
		delete window has been confirmed by the user
============================================================================*/
procedure Dm_Nodes_Delete (
p_node_id   IN VARCHAR2   DEFAULT NULL
);

/*===========================================================================

Function	choose home

Purpose		Choose your home document management node.  You can only
                search or add to one document management system at a time.
		This function allows you change which document system you
		are currently pointing at.
============================================================================*/
procedure choose_home (username IN VARCHAR2 DEFAULT NULL,
                       callback IN VARCHAR2 DEFAULT NULL);

procedure Product_LOV (p_titles_only   IN VARCHAR2 DEFAULT NULL,
                       p_find_criteria IN VARCHAR2 DEFAULT NULL);


/*===========================================================================

Function	get_document_attributes

Purpose		gets the current document meta data

============================================================================*/
PROCEDURE get_document_attributes (
username               IN  Varchar2,
document_identifier    in  varchar2,
document_attributes    out NOCOPY fnd_document_management.fnd_document_attributes);

/*===========================================================================

Function	set_document_form_fields

Purpose		Copy the document id and name to fields on a form.  This
		function is meant to fix the browser security issue of not
		being able to call javascript from one window page to another
		when those two pages are sourced by more than one server.

============================================================================*/
PROCEDURE set_document_form_fields (document_identifier    in  varchar2);

/*===========================================================================

Function	get_document_token_value

Purpose		gets a token attribute from an attribute page based on
                the requested token that is passed in

============================================================================*/
PROCEDURE get_document_token_value (document_text         IN VARCHAR2,
                                    requested_token       IN VARCHAR2,
                                    token_value           OUT NOCOPY VARCHAR2);

/*===========================================================================

Function	show_transport_message

Purpose		Displays a message in the transport window when a document
                has been selected and then closes itself and the document
		management window.

============================================================================*/
PROCEDURE show_transport_message;

/*===========================================================================

Function	get_ticket

Purpose		Get the current value of the ticket.  If the ticket
                is not set then create a random number and insert it

============================================================================*/
FUNCTION get_ticket (username     IN VARCHAR2) RETURN VARCHAR2;

/*===========================================================================

Function	validate_ticket

Purpose		Function for the DM system to validate the current value
		of the ticket for single signon.  We will create the initial
		value for the ticket.  We will then pass that ticket to the
		functions that the user can execute.  The DM vendor will
		then call us back through a database link or HTTP request
		to verify the value of the ticket.  If the ticket is valid
                then the DM vendor will create a new value for the ticket
                and pass it to us.  They will keep track of the value
                in that ticket so don't have to continually call this
		function to validate the ticket.  This function is
		only available through a sql*net database link since you
		cannot have OUT parameters for a HTTP request.

valid_ticket is returned with a value:

 0 = invalid ticket
 1 = valid ticket

============================================================================*/
PROCEDURE validate_ticket (username     IN VARCHAR2,
                           ticket       IN VARCHAR2,
                           valid_ticket OUT NOCOPY NUMBER);


/*===========================================================================

Function	validate_ticket_http

Purpose		Function for the DM system to validate the current value
		of the ticket for single signon.  We will create the initial
		value for the ticket.  We will then pass that ticket to the
		functions that the user can execute.  The DM vendor will
		then call us back through a database link or HTTP request
		to verify the value of the ticket.  If the ticket is valid
                then the DM vendor will create a new value for the ticket
                and pass it to us.  They will keep track of the value
                in that ticket so don't have to continually call this
		function to validate the ticket.  This function is
		only available through a sql*net database link since you
		cannot have OUT parameters for a HTTP request.

valid_ticket is returned with a value:

 <VALIDTICKET>0</VALIDTICKET> = invalid ticket
 <VALIDTICKET>1</VALIDTICKET> = valid ticket

============================================================================*/
PROCEDURE validate_ticket_HTTP (username    IN VARCHAR2,
                                ticket      IN VARCHAR2);

/*===========================================================================

Function	modulate_ticket

Purpose		Function for the DM system to update the current value
		of the ticket for single signon.  The DM vendor will
		create a value of the ticket and pass it to us.  They will
                keep track of the value in that ticket so when we call them
		with the value they will know what that value is so they
		do not have to continually revalidate the ticket in
		our system.

                If the ticket value is null then we will create a random
		number and plug it in.

============================================================================*/
PROCEDURE modulate_ticket (username    IN VARCHAR2,
                           ticket      IN VARCHAR2);

PROCEDURE test (stringy    IN VARCHAR2);

PROCEDURE show_test_message (

document_id  IN VARCHAR2,
display_type IN VARCHAR2,
document     IN OUT NOCOPY VARCHAR2,
document_type IN OUT NOCOPY VARCHAR2);

end FND_DOCUMENT_MANAGEMENT;

/
