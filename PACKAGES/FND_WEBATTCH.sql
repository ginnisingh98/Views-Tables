--------------------------------------------------------
--  DDL for Package FND_WEBATTCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_WEBATTCH" AUTHID CURRENT_USER as
/* $Header: AFATCHMS.pls 120.3.12010000.3 2012/06/26 14:33:52 ctilley ship $ */


-- GetSummaryStatus
-- IN
--	function_name	- Function name of the web function
--	entity_name	- Entity name to which the attachment is made.
--	pk1_value	- First primary key of the entity.
--	 through
--	pk5_value	- Fifth primary key value of the entity.
-- 	attchmt_status	- Indicates Attachment Status -
--				 EMPTY, FULL, DISABLED.
--
procedure GetSummaryStatus (
	x_function_name		in varchar2,
	x_entity_name		in varchar2,
	x_pk1_value		in varchar2,
	x_pk2_value		in varchar2	default NULL,
	x_pk3_value		in varchar2	default NULL,
	x_pk4_value		in varchar2	default NULL,
	x_pk5_value		in varchar2	default NULL,
	attchmt_status		out NOCOPY varchar2
);

-- GetSummaryList
--  IN
-- 	attchmt_status	- Indicates Attachment Status -
--				 EMPTY, FULL, DISABLED.
--	URL		- URL string to linked to the attachment button.
--	from_url	- URL from which the attachments is invoked from.
--			  This is required to set the back link.
--	query_only	- Query flag is set 'Y' when called in query only
--			  mode.
--

procedure GetSummaryList(
	attchmt_status		in varchar2 default 'DISABLED', -- Bug 1850949 - added default value
	from_url		in varchar2,
	query_only		in varchar2	default 'N',
	package_name		in varchar2	default 'FND_WEBATTCH',
	URL			out NOCOPY varchar2
 );

--
-- Summary
--	Construct the list of attachments for an entity.
-- IN
--	function_name	- Function name of the web function
--	entity_name	- Entity name to which the attachment is made.
--	pk1_value	- First primary key of the entity.
--	 through
--	pk5_value	- Fifth primary key value of the entity.
--	from_url	- URL from which the attachments is invoked from.
--			  This is required to set the back link.
--	query_only	- Query flag is set 'Y' when called in query only
--			  mode.
--

procedure Summary(
	function_name		in varchar2,
	entity_name		in varchar2,
	pk1_value		in varchar2,
	pk2_value		in varchar2	default NULL,
	pk3_value		in varchar2	default NULL,
	pk4_value		in varchar2	default NULL,
	pk5_value		in varchar2	default NULL,
	from_url		in varchar2,
	query_only		in varchar2	default 'N'
);

--
-- UpdateAttachment
--	Display the attachment information for update.
-- IN
--	attached_document_id
--	function_name	- Function name of the web function
--	entity_name	- Entity name to which the attachment is made.
--	pk1_value	- First primary key of the entity.
--	 through
--	pk5_value	- Fifth primary key value of the entity.
--	from_url	- URL from which the attachments is invoked from.
--			  This is required to set the back link.
--	query_only	- Query flag is set 'Y' when called in query only
--			  mode.
--

procedure UpdateAttachment(
	attached_document_id	in varchar2,
	function_name		in varchar2,
	entity_name		in varchar2,
	pk1_value		in varchar2,
	pk2_value		in varchar2	default NULL,
	pk3_value		in varchar2	default NULL,
	pk4_value		in varchar2	default NULL,
	pk5_value		in varchar2	default NULL,
	from_url		in varchar2,
	query_only		in varchar2	default 'N'
);

--
-- DeleteAttachment
--	Deletes the attachment and document.
-- IN
--	attached_document_id
--	function_name	- Function name of the web function
--	entity_name	- Entity name to which the attachment is made.
--	pk1_value	- First primary key of the entity.
--	 through
--	pk5_value	- Fifth primary key value of the entity.
--	from_url	- URL from which the attachments is invoked from.
--			  This is required to set the back link.
--	query_only	- Query flag is set 'Y' when called in query only
--			  mode.
--

procedure DeleteAttachment(
	attached_document_id	in varchar2,
	function_name		in varchar2,
	entity_name		in varchar2,
	pk1_value		in varchar2,
	pk2_value		in varchar2	default NULL,
	pk3_value		in varchar2	default NULL,
	pk4_value		in varchar2	default NULL,
	pk5_value		in varchar2	default NULL,
	from_url		in varchar2,
	query_only		in varchar2	default 'N'
);

-- AddAttachment
--	Creates an attachment and document.
-- IN
--	function_name	- Function name of the web function
--	entity_name	- Entity name to which the attachment is made.
--	pk1_value	- First primary key of the entity.
--	 through
--	pk5_value	- Fifth primary key value of the entity.
--	from_url	- URL from which the attachments is invoked from.
--			  This is required to set the back link.
--	query_only	- Query flag is set 'Y' when called in query only
--			  mode.
--

procedure AddAttachment(
	function_name		in varchar2,
	entity_name		in varchar2,
	pk1_value		in varchar2,
	pk2_value		in varchar2	default NULL,
	pk3_value		in varchar2	default NULL,
	pk4_value		in varchar2	default NULL,
	pk5_value		in varchar2	default NULL,
	from_url		in varchar2,
	query_only		in varchar2	default 'N'
 );

-- ViewTextDocument
--	View the document information of an attachment.
-- IN
--	attached_document_id - Reference to the attached document
--	function_name	- Function name of the web function
--	entity_name	- Entity name to which the attachment is made.
--	pk1_value	- First primary key of the entity.
--	 through
--	pk5_value	- Fifth primary key value of the entity.
--	from_url	- URL from which the attachments is invoked from.
--			  This is required to set the back link.
--	query_only	- Query flag is set 'Y' when called in query only
--			  mode.
--

procedure ViewTextDocument(
	attached_document_id	in 	varchar2,
	function_name		in	varchar2	,
	entity_name		in	varchar2	,
	pk1_value		in	varchar2	,
	pk2_value		in	varchar2	default NULL,
	pk3_value		in	varchar2	default NULL,
	pk4_value		in	varchar2	default NULL,
	pk5_value		in	varchar2	default NULL,
	from_url		in 	varchar2,
	query_only		in 	varchar2	default 'N'
 );

-- ViewFileDocument
--	Displays the file document.
-- IN
--	attached_document_id - Unique id for an attachment.
--

procedure ViewFileDocument (
	attached_document_id	in varchar2
);

PROCEDURE add_attachment_gfm_wrapper(
	access_id NUMBER,
        seq_num VARCHAR2 ,
        category_id VARCHAR2,
        document_description VARCHAR2,
        datatype_id VARCHAR2,
        text VARCHAR2 DEFAULT NULL,
        file_name VARCHAR2 DEFAULT NULL,
        url VARCHAR2 DEFAULT NULL,
        function_name VARCHAR2 DEFAULT NULL,
        entity_name VARCHAR2 DEFAULT NULL,
        pk1_value VARCHAR2 DEFAULT NULL,
        pk2_value VARCHAR2 DEFAULT NULL,
        pk3_value VARCHAR2 DEFAULT NULL,
        pk4_value VARCHAR2 DEFAULT NULL,
        pk5_value VARCHAR2 DEFAULT NULL,
        from_url VARCHAR2 DEFAULT NULL,
        query_only VARCHAR2 DEFAULT NULL,
	user_id    VARCHAR2 DEFAULT NULL,
        dmid       VARCHAR2 DEFAULT NULL,
        dmname     VARCHAR2 DEFAULT NULL,
        package_name VARCHAR2 DEFAULT 'FND_WEBATTCH',
        dm_node                 in number   DEFAULT NULL,
        dm_folder_path          in varchar2 DEFAULT NULL,
        dm_type                 in varchar2 DEFAULT NULL,
        dm_document_id          in number   DEFAULT NULL,
        dm_version_number       in varchar2 DEFAULT NULL,
        title                   in varchar2 DEFAULT NULL
        );

-- Add_Attachment
-- IN
--	seq_num		- Attachment Seq Number.
--	category_description
--	document_description
--	datatype_name	- Datatype identifier
--	document_text	- Document Text Input.
--	file_name	- File name
--	URL		- URL
--	function_name	--Function name of the form
--	entity_name	- Entity name for which attachment is made.
--	pk1_value	- First Primary Key value of the entity.
--	  to
--	pk5_value	- Fifth Primary key value of the entity.
--	media_id	- Document reference.
--      usage_type      - One-time, Standard, Template

procedure Add_Attachment (
        seq_num                 in varchar2                     ,
        category_id    		in varchar2                     ,
        document_description    in varchar2                     ,
        datatype_id		in varchar2                     ,
        text                    in long             	        ,
        file_name               in varchar2			,
        url                     in varchar2                     ,
	function_name		in varchar2			,
        entity_name             in varchar2                     ,
        pk1_value               in varchar2                     ,
        pk2_value               in varchar2                     ,
        pk3_value               in varchar2                     ,
        pk4_value               in varchar2                     ,
        pk5_value               in varchar2			,
	media_id		in number			,
	user_id			in varchar2                     ,
        usage_type              in varchar2 DEFAULT 'O'		,
	title			in varchar2 DEFAULT NULL        ,
        dm_node                 in number   DEFAULT NULL        ,
        dm_folder_path          in varchar2 DEFAULT NULL        ,
        dm_type                 in varchar2 DEFAULT NULL        ,
        dm_document_id          in number   DEFAULT NULL        ,
        dm_version_number       in varchar2 DEFAULT NULL
);

PROCEDURE update_attachment_gfm_wrapper(
        seq_num varchar2,
        category_id varchar2,
        document_description varchar2 DEFAULT NULL,
        text varchar2 DEFAULT NULL,
        file_name varchar2 DEFAULT NULL,
        url varchar2 DEFAULT NULL,
        attached_document_id varchar2 DEFAULT NULL,
        datatype_id varchar2,
        function_name varchar2 DEFAULT NULL,
        entity_name varchar2 DEFAULT NULL,
        pk1_value varchar2 DEFAULT NULL,
        pk2_value varchar2 DEFAULT NULL,
        pk3_value varchar2 DEFAULT NULL,
        pk4_value varchar2 DEFAULT NULL,
        pk5_value varchar2 DEFAULT NULL,
        from_url varchar2 DEFAULT NULL,
        query_only varchar2 DEFAULT NULL,
        dmid       VARCHAR2 DEFAULT NULL,
        dmname     VARCHAR2 DEFAULT NULL,
        package_name VARCHAR2 DEFAULT 'FND_WEBATTCH',
        dm_node    NUMBER DEFAULT NULL,
        dm_folder_path VARCHAR2 DEFAULT NULL,
        dm_type        VARCHAR2 DEFAULT NULL,
        dm_document_id NUMBER DEFAULT NULL,
        dm_version_number VARCHAR2 DEFAULT NULL,
        title             VARCHAR2 DEFAULT NULL
        );

-- Update_Attachment
-- IN
--	seq_num		- Attachment Seq Number.
--	category_id
--	document_description
--	datatype_id	- Datatype identifier
--	document_text	- Document Text Input.
--	file_name	- File name
--	URL		- URL
--	attached_document_id
--	function_name	- Function name of the form
--	entity_name	- Entity name for which attachment is made.
--	pk1_value	- First Primary Key value of the entity.
--	  to
--	pk5_value	- Fifth Primary key value of the entity.
--

procedure Update_Attachment (
	seq_num			in varchar2			,
	category_id		in varchar2			,
	document_description	in varchar2			,
	text			in long				,
	file_name		in varchar2			,
	url			in varchar2			,
	attached_document_id	in varchar2			,
	datatype_id		in varchar2			,
	function_name		in varchar2			,
	entity_name		in varchar2			,
	pk1_value		in varchar2			,
	pk2_value		in varchar2			,
	pk3_value		in varchar2			,
	pk4_value		in varchar2			,
	pk5_value		in varchar2			,
	media_id		in number			,
	user_id			in varchar2                     ,
        dm_node                 in NUMBER DEFAULT NULL          ,
        dm_folder_path          in VARCHAR2 DEFAULT NULL        ,
        dm_type                 in VARCHAR2 DEFAULT NULL        ,
        dm_document_id          in NUMBER DEFAULT NULL          ,
        dm_version_number       in VARCHAR2 DEFAULT NULL        ,
        title                   in VARCHAR2 DEFAULT NULL
);

-- ReloadSummary
--      Reloads the summarry after adding or updating attachment.
-- IN
--      package_name    - Calling package name.
--      function_name   - Function name of the form
--      entity_name     - Entity name for which attachment is made.
--      pk1_value       - First Primary Key value of the entity.
--        to
--      pk5_value       - Fifth Primary key value of the entity.
--      from_url        - URL from which the attachments is invoked from.
--                        This is required to set the back link.
--      query_only      - Query flag is set 'Y' when called in query only
--                        mode.
--

procedure ReloadSummary(
        package_name            in varchar2     default 'FND_WEBATTCH',
        function_name           in varchar2,
        entity_name             in varchar2,
        pk1_value               in varchar2,
        pk2_value               in varchar2     default NULL,
        pk3_value               in varchar2     default NULL,
        pk4_value               in varchar2     default NULL,
        pk5_value               in varchar2     default NULL,
        from_url                in varchar2                 ,
        query_only              in varchar2     default 'N'
);

-- Header
--	Creates Toolbar for Attachment pages.
-- IN
--	Lang	- Toolbar language.
--
procedure Header( Lang	in varchar2);

-- PrintSummary
--	Prints the attachment summary page body (No Titles and Links).
-- IN
--	package_name	- Calling package name.
--	function_name	- Function name of the web function
--	entity_name	- Entity name to which the attachment is made.
--	pk1_value	- First primary key of the entity.
--	 through
--	pk5_value	- Fifth primary key value of the entity.
--	from_url	- URL from which the attachments is invoked from.
--			  This is required to set the back link.
--	query_only	- Query flag is set 'Y' when called in query only
--			  mode.
--

procedure PrintSummary(
	package_name		in varchar2	default 'FND_WEBATTCH',
	function_name		in varchar2,
	entity_name		in varchar2,
	pk1_value		in varchar2,
	pk2_value		in varchar2	default NULL,
	pk3_value		in varchar2	default NULL,
	pk4_value		in varchar2	default NULL,
	pk5_value		in varchar2	default NULL,
	from_url		in varchar2,
	query_only		in varchar2	default 'N'
);

-- PrintTextDocument
--	Prints the HTML page that displays text document information.
-- IN
--	package_name    - Calling package name.
--	attached_document_id - Reference to the attached document
--	function_name	- Function name of the web function
--	entity_name	- Entity name to which the attachment is made.
--	pk1_value	- First primary key of the entity.
--	 through
--	pk5_value	- Fifth primary key value of the entity.
--	from_url	- URL from which the attachments is invoked from.
--			  This is required to set the back link.
--	query_only	- Query flag is set 'Y' when called in query only
--			  mode.
--

procedure PrintTextDocument(
	package_name		in varchar2	default 'FND_WEBATTCH',
	attached_document_id	in varchar2,
	function_name		in varchar2	,
	entity_name		in varchar2	,
	pk1_value		in varchar2	,
	pk2_value		in varchar2	default NULL,
	pk3_value		in varchar2	default NULL,
	pk4_value		in varchar2	default NULL,
	pk5_value		in varchar2	default NULL,
	from_url		in varchar2,
	query_only		in varchar2	default 'N'
 );

-- PrintAddAttachment
--	Prints the HTML form to add attachment and document information.
-- IN
--	package_name    - Calling package name.
--	function_name	- Function name of the web function
--	entity_name	- Entity name to which the attachment is made.
--	pk1_value	- First primary key of the entity.
--	 through
--	pk5_value	- Fifth primary key value of the entity.
--	from_url	- URL from which the attachments is invoked from.
--			  This is required to set the back link.
--	query_only	- Query flag is set 'Y' when called in query only
--			  mode.
--

procedure PrintAddAttachment(
	package_name	in varchar2	default 'FND_WEBATTCH',
	function_name	in varchar2,
	entity_name	in varchar2,
	pk1_value	in varchar2,
	pk2_value	in varchar2	default NULL,
	pk3_value	in varchar2	default NULL,
	pk4_value	in varchar2	default NULL,
	pk5_value	in varchar2	default NULL,
	from_url	in varchar2,
	query_only	in varchar2	default 'N'
 );

-- PrintUpdateAttachment
--	Prints the HTML form to update attachment and document information.
-- IN
--	package_name    - Calling package name.
--	seq_num		- Attachment Seq Number.
--	attached_document_id
--	function_name	- Function name of the web function
--	entity_name	- Entity name to which the attachment is made.
--	pk1_value	- First primary key of the entity.
--	 through
--	pk5_value	- Fifth primary key value of the entity.
--	from_url	- URL from which the attachments is invoked from.
--			  This is required to set the back link.
--	query_only	- Query flag is set 'Y' when called in query only
--			  mode.
--

procedure PrintUpdateAttachment (
	package_name		in varchar2	default 'FND_WEBATTCH',
	attached_document_id	in varchar2,
	function_name		in varchar2,
	entity_name		in varchar2,
	pk1_value		in varchar2,
	pk2_value		in varchar2	default NULL,
	pk3_value		in varchar2	default NULL,
	pk4_value		in varchar2	default NULL,
	pk5_value		in varchar2	default NULL,
	from_url		in varchar2,
	query_only		in varchar2	default 'N'
);

procedure PrintBlankPage;

/*===========================================================================

Function        set_document_identifier

Purpose         This is call back implemented to pass the document reference
                identifier to the attachments.


file_id - A unique access key for document reference attributes
                        being attached to a application entity.

document_identifier - full concatenated document attribute strings.
        nodeid:libraryid:documentid:version:document_name

============================================================================*/
procedure set_document_identifier (
p_file_id               IN  VARCHAR2,
p_document_id   IN  VARCHAR2);

/*===========================================================================

Function        authorizeDMTransaction

Purpose         This will provide a secure key for DM transaction from forms.


file_id - 	A unique access key for document reference attributes
                being attached to a application entity.

============================================================================*/
procedure authorizeDMTransaction(
file_id OUT NOCOPY VARCHAR2);

end FND_WEBATTCH;

/
