--------------------------------------------------------
--  DDL for Package Body FND_DOCUMENT_MANAGEMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_DOCUMENT_MANAGEMENT" AS
/* $Header: AFWFDMGB.pls 120.8.12000000.3 2007/02/28 08:01:54 hgandiko ship $ */

/*
** We need need to fetch URL prefix from WF_WEB_AGENT in wf_resources
** since this function gets called from the forms environment
** which doesn't know anything about the cgi variables.
*/
dm_base_url varchar2(240) := wf_core.translate('WF_WEB_AGENT');

--
-- Error (PRIVATE)
--   Print a page with an error message.
--   Errors are retrieved from these sources in order:
--     1. wf_core errors
--     2. Oracle errors
--     3. Unspecified INTERNAL error
--
procedure Error
as
  error_name      varchar2(30);
  error_message   varchar2(2000);
  error_stack     varchar2(32000);
begin
    htp.htmlOpen;
    htp.headOpen;
    htp.title(wf_core.translate('ERROR'));
    htp.headClose;

    begin
      wfa_sec.Header(background_only=>TRUE);
    exception
      when others then
        htp.bodyOpen;
    end;

    htp.header(nsize=>1, cheader=>wf_core.translate('ERROR'));

    wf_core.get_error(error_name, error_message, error_stack);

    -- Bug5161758 - XSS
    error_message := wf_core.substitutespecialchars(error_message);
    error_stack := wf_core.substitutespecialchars(error_stack);

    if (error_name is not null) then
        htp.p(error_message);
    else
        htp.p(sqlerrm);
    end if;

    htp.hr;
    htp.p(wf_core.translate('WFENG_ERRNAME')||':  '||error_name);
    htp.br;
    htp.p(wf_core.translate('WFENG_ERRSTACK')||': '||
          replace(error_stack,wf_core.newline,'<br>'));

    wfa_sec.Footer;
    htp.htmlClose;
end Error;

/*===========================================================================

Procedure	get_product_parameter_list

Purpose		Retrieves the parameters for a specific implementation for
		a function and product

============================================================================*/
PROCEDURE get_product_parameter_list
(product_function_id IN  NUMBER,
 parameter_list      OUT NOCOPY fnd_document_management.fnd_dm_product_parms_tbl_type
)
IS

/*
** c_fetch_function_parameters fetches the parameters for a specific
** implementation of a function by a DM vendor
*/
CURSOR c_fetch_function_parameters
(c_product_function_id IN Number) IS
SELECT  dmparm.parameter_name,
        dmprod.parameter_syntax
FROM   fnd_dm_function_parameters dmparm,
       fnd_dm_product_parm_syntax dmprod
WHERE  dmprod.product_function_id = c_product_function_id
AND    dmprod.parameter_id = dmparm.parameter_id
ORDER BY dmparm.parameter_name;

l_record_num   NUMBER := 0;

BEGIN

   /*
   ** Fetch the parameters for the display function for the vendor
   ** that is installed on the selected node
   */
   OPEN  c_fetch_function_parameters(product_function_id);

   /*
   ** Loop through all the parameters for the given function
   ** building the l_parameter_list variable
   */
   LOOP

      l_record_num := l_record_num + 1;

      FETCH c_fetch_function_parameters INTO
         parameter_list(l_record_num);

      EXIT WHEN c_fetch_function_parameters%NOTFOUND;


   END LOOP;

   EXCEPTION
   WHEN OTHERS THEN
      Wf_Core.Context('fnd_document_management',
                      'get_product_parameter_list',
                      to_char(product_function_id));
      RAISE;

END get_product_parameter_list;

/*===========================================================================

Procedure	get_function_definition

Purpose		Retrieves the node and function definition for a give node
                function and vendor who is servicing that node.

============================================================================*/
PROCEDURE get_function_definition
(p_node_id              IN  NUMBER,
 p_function_name        IN  VARCHAR2,
 p_node_syntax          OUT NOCOPY VARCHAR2,
 p_product_id           OUT NOCOPY NUMBER,
 p_function_syntax      OUT NOCOPY VARCHAR2,
 p_product_function_id  OUT NOCOPY NUMBER,
 p_icon_name            OUT NOCOPY VARCHAR2)

IS

BEGIN

    /*
    ** See if you can find the name in the document management reference system
    ** Get the URL prefix for the route to the DM host and the product id
    ** Also get the appropriate syntax for a display function for the vendor
    ** that is servicing this particular node.
    */
    BEGIN

        SELECT dmnode.connect_syntax,
               dmnode.product_id,
               dmprod.function_syntax,
               dmprod.product_function_id,
               dmfunc.icon_name
        INTO   p_node_syntax,
               p_product_id,
               p_function_syntax,
               p_product_function_id,
               p_icon_name
        FROM   fnd_dm_product_function_syntax dmprod,
               fnd_dm_functions dmfunc,
               fnd_dm_nodes dmnode
        WHERE  dmnode.node_id       = p_node_id
        AND    dmnode.product_id    = dmprod.product_id
        AND    dmfunc.function_name = p_function_name
        AND    dmprod.function_id = dmfunc.function_id;

    /*
    ** No data found is an exceptable response for this query.  It means that
    ** the fetch function is not supported by the particular dm vendor
    ** software.  I can't imagine what vendor would not support a fetch
    ** function but who knows.  Set the  display_document_URL to null in
    ** this case.
    */
    EXCEPTION
       WHEN no_data_found THEN
          p_node_syntax := NULL;
          p_product_id := 0;
          p_function_syntax := NULL;
          p_product_function_id := 0;
          p_icon_name := NULL;
       WHEN OTHERS THEN
          Wf_Core.Context('fnd_document_management',
                          'get_function_defintion',
                          to_char(p_node_id),
                          p_function_name);
          RAISE;

    END;

   EXCEPTION
   WHEN OTHERS THEN
      Wf_Core.Context('fnd_document_management',
                      'get_function_defintion',
                      to_char(p_node_id),
                      p_function_name);
      RAISE;

END get_function_definition;

/*===========================================================================

Procedure	create_html_syntax

Purpose		Create the proper syntax for displaying the function
                and the associate icon with proper HTML syntax.

============================================================================*/
PROCEDURE create_html_syntax
(p_html_formatting      IN  BOOLEAN,
 p_function_name        IN  VARCHAR2,
 p_node_connect_syntax  IN  VARCHAR2,
 p_function_syntax      IN  VARCHAR2,
 p_parameter_syntax     IN  VARCHAR2,
 p_resource_name        IN  VARCHAR2,
 p_icon_name            IN  VARCHAR2,
 p_document_html        OUT NOCOPY VARCHAR2)

IS

BEGIN

  /*
  ** Check if the caller wishes to construct html syntax that includes
  ** the appropriate icon and tranlated function name for this URL.
  */
  IF (p_html_formatting = TRUE AND p_function_syntax IS NOT NULL) THEN

      /*
      ** Populate the display_document_URL with the full HTML syntax to
      ** draw and icon and a function name for the display function.
      ** Also get the translated string for the function display name
      */
      if (p_function_name IN ('get_search_document_url',
                              'get_create_document_url',
		  	      'get_browse_document_url')) THEN
         p_document_html  :=
            '<IMG SRC="'||wfa_html.image_loc||p_icon_name||'" alt="' ||
            p_resource_name || '">'||
            '<A HREF="javascript:fnd_open_dm_attach_window(' || '''' ||
              p_node_connect_syntax||p_function_syntax||p_parameter_syntax||
             '''' ||
            ', 700, 600)">'||
            p_resource_name ||
            ' </A>';

      else

         p_document_html  :=
            '<IMG SRC="'||wfa_html.image_loc||p_icon_name||'" alt="' ||
            p_resource_name || '">'||
            '<A HREF="javascript:fnd_open_dm_display_window(' || '''' ||
              p_node_connect_syntax||p_function_syntax||p_parameter_syntax||
             '''' ||
            ', 700, 600)">'||
            p_resource_name ||
            ' </A>';
      end if;

   ELSIF (p_function_syntax IS NOT NULL) THEN

      /*
      ** Populate the display_document_URL with just the sting for the URL
      ** and leave the formatting up to the caller.
      */
      p_document_html :=
         p_node_connect_syntax||p_function_syntax||p_parameter_syntax;

   ELSE

      p_document_html := null;

   END IF;

   EXCEPTION
   WHEN OTHERS THEN
      Wf_Core.Context('fnd_document_management',
                      'create_html_syntax',
                      p_function_name,
                      p_node_connect_syntax,
                      p_function_syntax,
                      p_parameter_syntax,
                      p_resource_name);
      RAISE;

END create_html_syntax;


/*===========================================================================

Function	get_launch_document_url

Purpose		Set up the anchor to launch a new window with a frameset
                with two frames.  The upper frame has all the controls.
                The lower frame displays the document.

============================================================================*/
PROCEDURE get_launch_document_url
(username             IN  Varchar2,
 document_identifier  IN  Varchar2,
 display_icon         IN  Boolean,
 launch_document_URL OUT NOCOPY Varchar2) IS

l_product_id            Number := 0;
l_dm_node_id            Number := 0;
l_document_id           Varchar2(30) := NULL;
l_version               Varchar2(10) := NULL;
l_document_name         Varchar2(240) := NULL;
l_username              Varchar2(320);   -- Username to query /*Bug2001012*/
l_document_url          Varchar2(4000) := NULL;
l_document_attributes   fnd_document_management.fnd_document_attributes;
l_dummy                 boolean; -- Bug5161758 HTML injection

BEGIN
    -- Bug5161758 HTML injection
    begin
      l_dummy := wf_core.CheckIllegalChars(username,true);
    exception
      when OTHERS then
        fnd_document_management.error;
        return;
    end;
    l_username := upper(username);

    /*
    ** get all the components of the document attribute
    */
    fnd_document_management.ParseDocInfo(document_identifier,
                                         l_dm_node_id,
                                         l_document_id,
                                         l_version);

    /*
    ** get the product that is installed for that dm node
    */
    SELECT MAX(PRODUCT_ID)
    INTO   l_product_id
    FROM   fnd_dm_nodes
    WHERE  node_id = l_dm_node_id;


    /*
    ** get all the components of the document anchor
    */
    IF (display_icon = FALSE) THEN

       /*
       ** If the product id = 1 then this is an Internet Documents install
       ** We do not display the multiframe window in this case with the
       ** control bar on top.  Internet documents has their own toolbar and
       ** has their own mechanism for controlling the DM options.
       */
       IF (l_product_id = 1) THEN

          /*
          ** Get the HTML text for displaying the document
          */
          fnd_document_management.get_display_document_url (
              l_username,
              document_identifier,
              FALSE,
              FALSE,
              l_document_url);

          launch_document_URL := l_document_url;

       ELSE

          launch_document_URL := dm_base_url||
             '/fnd_document_management.create_display_document_url?'||
             'document_identifier='||
              wfa_html.conv_special_url_chars(document_identifier)||
             '&username='||l_username;

      END IF;

    ELSE

       /*
       ** get the document name
       */
       fnd_document_management.get_document_attributes(l_username,
            document_identifier,
            l_document_attributes);


       l_document_name := l_document_attributes.document_name;

       /*
       ** If the product id = 1 then this is an Internet Documents install
       ** We do not display the multiframe window in this case with the
       ** control bar on top.  Internet documents has their own toolbar and
       ** has their own mechanism for controlling the DM options.
       */
       IF (l_product_id = 1) THEN

          /*
          ** Get the HTML text for displaying the document
          */
          fnd_document_management.get_display_document_url (
              l_username,
              document_identifier,
              FALSE,
              FALSE,
              l_document_url);

          launch_document_URL :=
             '<A HREF="javascript:fnd_open_dm_display_window(' || '''' ||
               l_document_url||
             '''' ||
             ', 700, 600)">'||
             l_document_name||
             ' </A>';

       ELSE

          launch_document_URL :=
             '<A HREF="javascript:fnd_open_dm_display_window(' || '''' ||
             dm_base_url||
             '/fnd_document_management.create_display_document_url?'||
             'document_identifier='||
              wfa_html.conv_special_url_chars(document_identifier)||
             '&username='||l_username||
             '''' ||
             ', 700, 600)">'||
             l_document_name||
             ' </A>';

      END IF;

    END IF;

    EXCEPTION
    WHEN OTHERS THEN
       Wf_Core.Context('fnd_document_management',
                       'get_launch_document_url',
                       document_identifier);
       RAISE;

END get_launch_document_url;

/*===========================================================================

Function	create_display_document_url

Purpose		Launches the toolbar in one frame for the document
                operations and then creates another frame to display
                the document.

============================================================================*/
PROCEDURE create_display_document_url
(username             IN  Varchar2,
 document_identifier  IN  Varchar2) IS

l_dm_node_id            Number := 0;
l_document_id           Varchar2(30) := NULL;
l_version               Varchar2(10) := NULL;
l_document_url          Varchar2(2000) := NULL;
l_dummy                 boolean; -- Bug5161758 HTML injection

BEGIN
  -- Bug5161758 HTML injection
  begin
    l_dummy := wf_core.CheckIllegalChars(username,true);
  exception
    when OTHERS then
      fnd_document_management.error;
      return;
  end;

  /*
  ** Create the top header frameset and the bottom summary/detail frameset
  */
  htp.p ('<FRAMESET ROWS="15%,85%" BORDER=0 LONGDESC="'||
          owa_util.get_owa_service_path ||
          'wfa_html.LongDesc?p_token=WFDM_LONGDESC">');

  /*
  ** Create the header frame
  */
  htp.p ('<FRAME NAME=CONTROLS '||
         'SRC='||
         dm_base_url||
         '/fnd_document_management.create_document_toolbar?'||
         'document_identifier='||
         wfa_html.conv_special_url_chars(document_identifier)||
         '&username='||username||
         ' MARGINHEIGHT=10 MARGINWIDTH=10 '||
         'SCROLLING="NO" NORESIZE FRAMEBORDER=YES LONGDESC="'||
          owa_util.get_owa_service_path ||
         'wfa_html.LongDesc?p_token=WFDM_LONGDESC">');

   /*
   ** Get the HTML text for displaying the document
   */
   fnd_document_management.get_display_document_url (
      username,
      document_identifier,
      FALSE,
      FALSE,
      l_document_url);

   htp.p ('<FRAME NAME=DOCUMENT '||
          'SRC='||
           l_document_url ||
           ' MARGINHEIGHT=10 MARGINWIDTH=10 '||
           'NORESIZE SCROLLING="YES" FRAMEBORDER=NO LONGDESC="'||
          owa_util.get_owa_service_path ||
         'wfa_html.LongDesc?p_token=WFDM_LONGDESC">');

   /*
   ** Close the summary/details frameset
   */
   htp.p ('</FRAMESET>');

   EXCEPTION
   WHEN OTHERS THEN
       Wf_Core.Context('fnd_document_management',
                       'create_display_document_url',
                       document_identifier);
       RAISE;

END create_display_document_url;


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

============================================================================*/
PROCEDURE get_search_document_url
(username               IN  Varchar2,
 callback_function 	IN  Varchar2,
 html_formatting 	IN  Boolean,
 search_document_URL 	OUT NOCOPY Varchar2) IS

l_product_id            Number  := 0;
l_product_function_id   Number  := 0;
l_record_num            Number  := 0;
l_node_connect_syntax   Varchar2(240)  := '';
l_parameter_str         Varchar2(4000) := '';
l_function_syntax       Varchar2(4000)  := '';
l_icon_name             Varchar2(40)   := '';
l_parameter_list        fnd_document_management.fnd_dm_product_parms_tbl_type;
l_username              Varchar2(320);   -- Username to query
l_dm_node_id            Number;         -- Document Management Home preference
l_dm_node_name          Varchar2(240);
l_dummy                 boolean; -- Bug5161758 HTML injection

BEGIN
    -- Bug5161758 HTML injection
    begin
      l_dummy := wf_core.CheckIllegalChars(username,true);
    exception
      when OTHERS then
        fnd_document_management.error;
        return;
    end;
    l_username := upper(username);

    -- get the document management home node information
    fnd_document_management.get_dm_home (l_username, l_dm_node_id, l_dm_node_name);

    /*
    ** Get the URL prefix for the route to the DM host and the product id
    ** Also get the appropriate syntax for a search function for the vendor
    ** that is servicing this particular node.
    */
    get_function_definition (l_dm_node_id,
                             'get_search_document_url',
                             l_node_connect_syntax,
                             l_product_id,
                             l_function_syntax,
                             l_product_function_id,
                             l_icon_name);

    /*
    ** Go get the parameters for this function for the specific
    ** vendor software that is servicing this particular node
    */
    IF (l_function_syntax IS NOT NULL) THEN

      /*
      ** Get the parameters for the search function
      */
      get_product_parameter_list (l_product_function_id,
 				  l_parameter_list);

      /*
      ** Loop through the parameter list filling in the corresponding
      ** values
      */
      FOR l_record_num IN 1..l_parameter_list.count LOOP

         /*
         ** Determine which argument separator to add
         */

         IF (INSTR(l_parameter_str, '?') > 0 OR
              INSTR(l_function_syntax, '?') > 0) THEN

             l_parameter_str := l_parameter_str || '&';

         ELSE

             l_parameter_str := l_parameter_str || '?';

         END IF;

         IF (l_parameter_list(l_record_num).parameter_name = 'CALLBACK') THEN

             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 callback_function;

         ELSIF (l_parameter_list(l_record_num).parameter_name = 'USERNAME') THEN

             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 username;

         ELSIF (l_parameter_list(l_record_num).parameter_name = 'TICKET') THEN

             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 fnd_document_management.get_ticket(username);

         END IF;

      END LOOP;

    END IF;

    /*
    ** Create the proper html syntax for the document function
    */
    create_html_syntax (html_formatting,
                        'get_search_document_url',
                        l_node_connect_syntax,
                        l_function_syntax,
                        l_parameter_str,
                        'WFDM_SEARCH',
                        l_icon_name,
                        search_document_url);

    EXCEPTION
    WHEN OTHERS THEN
       Wf_Core.Context('fnd_document_management',
                       'get_search_document_url');
       RAISE;

END get_search_document_url;

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

============================================================================*/
PROCEDURE get_create_document_url
(username               IN  Varchar2,
 callback_function 	IN  Varchar2,
 html_formatting 	IN  Boolean,
 create_document_URL 	OUT NOCOPY Varchar2) IS

l_product_id            Number  := 0;
l_product_function_id   Number  := 0;
l_record_num            Number  := 0;
l_node_connect_syntax   Varchar2(240)  := '';
l_parameter_str         Varchar2(4000) := '';
l_function_syntax       Varchar2(4000)  := '';
l_icon_name             Varchar2(40)   := '';
l_parameter_list        fnd_document_management.fnd_dm_product_parms_tbl_type;
l_username              Varchar2(320);   -- Username to query
l_dm_node_id            Number;         -- Document Management Home preference
l_dm_node_name          Varchar2(240);
l_browser               varchar2(400);
l_callback_function     Varchar2(4000);
l_dummy                 boolean; -- Bug5161758 HTML injection

BEGIN
    -- Bug5161758 HTML injection
    begin
      l_dummy := wf_core.CheckIllegalChars(username,true);
    exception
      when OTHERS then
        fnd_document_management.error;
        return;
    end;
    /*
    ** The forms attachments interface calls this same function to
    ** get the proper url to attach a document to a business object.
    ** Since the forms launch process is not within a browser the
    ** owa_util variables will not be available when this string
    ** gets created.  We check here whether your calling this from
    ** a web interface or a forms interface.
    */
    IF (html_formatting = TRUE) THEN

       l_browser := owa_util.get_cgi_env('HTTP_USER_AGENT');

    ELSE

       l_browser := 'NETSCAPE';

    END IF;

    l_username := upper(username);

    -- get the document management home node information
    fnd_document_management.get_dm_home (l_username, l_dm_node_id, l_dm_node_name);


    /*
    ** This is a total hack but it must be done for now for simplicity of
    ** the interface.  Netscape has another layer of objects that must
    ** be referenced when calling it through javascript.  Thus if you
    ** are not using IE then add another opener.parent to the hierarchy.
    ** We have two different calls because it depends if you are calling
    ** this from the multiframe response window or from a single frame window.
    */
    IF (instr(owa_util.get_cgi_env('HTTP_USER_AGENT'), 'MSIE') = 0) THEN

        l_callback_function := REPLACE(callback_function,
                                       'opener.parent.bottom.document',
                                       'opener.parent.opener.parent.bottom.document');


        l_callback_function := REPLACE(l_callback_function,
                                     'top.opener.parent.document',
                                      'top.parent.opener.parent.opener.document');

     ELSE

        l_callback_function := callback_function;

     END IF;

    /*
    ** Get the URL prefix for the route to the DM host and the product id
    ** Also get the appropriate syntax for a create function for the vendor
    ** that is servicing this particular node.
    */
    get_function_definition (l_dm_node_id,
                             'get_create_document_url',
                             l_node_connect_syntax,
                             l_product_id,
                             l_function_syntax,
                             l_product_function_id,
                             l_icon_name);

    /*
    ** Go get the parameters for this function for the specific
    ** vendor software that is servicing this particular node
    */
    IF (l_function_syntax IS NOT NULL) THEN

      /*
      ** Get the parameters for the create function
      */
      get_product_parameter_list (l_product_function_id,
 				  l_parameter_list);

      /*
      ** Loop through the parameter list filling in the corresponding
      ** values
      */
      /*
      ** Loop through the parameter list filling in the corresponding
      ** values
      */
      FOR l_record_num IN 1..l_parameter_list.count LOOP

         /*
         ** Determine which argument separator to add
         */

         IF (INSTR(l_parameter_str, '?') > 0 OR
              INSTR(l_function_syntax, '?') > 0) THEN

             l_parameter_str := l_parameter_str || '&';

         ELSE

             l_parameter_str := l_parameter_str || '?';

         END IF;

         IF (l_parameter_list(l_record_num).parameter_name = 'CALLBACK') THEN

             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 l_callback_function;

         ELSIF (l_parameter_list(l_record_num).parameter_name = 'USERNAME') THEN

             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 username;

         ELSIF (l_parameter_list(l_record_num).parameter_name = 'TICKET') THEN

             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 fnd_document_management.get_ticket(username);

         END IF;

      END LOOP;

    END IF;

    /*
    ** Create the proper html syntax for the document function
    */
    create_html_syntax (html_formatting,
                        'get_create_document_url',
                        l_node_connect_syntax,
                        l_function_syntax,
                        l_parameter_str,
                        'WFDM_CREATE',
                        l_icon_name,
                        create_document_url);

    EXCEPTION
    WHEN OTHERS THEN
       Wf_Core.Context('fnd_document_management',
                       'get_create_document_url',
                       callback_function);
       RAISE;

END get_create_document_url;

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
 browse_document_URL 	OUT NOCOPY Varchar2) IS

l_product_id            Number  := 0;
l_product_function_id   Number  := 0;
l_record_num            Number  := 0;
l_node_connect_syntax   Varchar2(240)  := '';
l_parameter_str         Varchar2(4000) := '';
l_function_syntax       Varchar2(4000)  := '';
l_icon_name             Varchar2(40)   := '';
l_parameter_list        fnd_document_management.fnd_dm_product_parms_tbl_type;
l_username              Varchar2(320);   -- Username to query
l_dm_node_id            Number;         -- Document Management Home preference
l_dm_node_name          Varchar2(240);
l_dummy                 boolean; -- Bug5161758 HTML injection

BEGIN
    -- Bug5161758 HTML injection
    begin
      l_dummy := wf_core.CheckIllegalChars(username,true);
    exception
      when OTHERS then
        fnd_document_management.error;
        return;
    end;
    l_username := upper(username);

    -- get the document management home node information
    fnd_document_management.get_dm_home (l_username, l_dm_node_id, l_dm_node_name);

    /*
    ** Get the URL prefix for the route to the DM host and the product id
    ** Also get the appropriate syntax for a create function for the vendor
    ** that is servicing this particular node.
    */
    get_function_definition (l_dm_node_id,
                             'get_browse_document_url',
                             l_node_connect_syntax,
                             l_product_id,
                             l_function_syntax,
                             l_product_function_id,
                             l_icon_name);

    /*
    ** Go get the parameters for this function for the specific
    ** vendor software that is servicing this particular node
    */
    IF (l_function_syntax IS NOT NULL) THEN

      /*
      ** Get the parameters for the create function
      */
      get_product_parameter_list (l_product_function_id,
 				  l_parameter_list);

      /*
      ** Loop through the parameter list filling in the corresponding
      ** values
      */
      /*
      ** Loop through the parameter list filling in the corresponding
      ** values
      */
      FOR l_record_num IN 1..l_parameter_list.count LOOP

         /*
         ** Determine which argument separator to add
         */

         IF (INSTR(l_parameter_str, '?') > 0 OR
              INSTR(l_function_syntax, '?') > 0) THEN

             l_parameter_str := l_parameter_str || '&';

         ELSE

             l_parameter_str := l_parameter_str || '?';

         END IF;

         IF (l_parameter_list(l_record_num).parameter_name = 'CALLBACK') THEN

             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 callback_function;

         ELSIF (l_parameter_list(l_record_num).parameter_name = 'USERNAME') THEN

             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 username;

         ELSIF (l_parameter_list(l_record_num).parameter_name = 'TICKET') THEN

             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 fnd_document_management.get_ticket(username);

         END IF;

      END LOOP;

    END IF;

    /*
    ** Create the proper html syntax for the document function
    */
    create_html_syntax (html_formatting,
                        'get_browse_document_url',
                        l_node_connect_syntax,
                        l_function_syntax,
                        l_parameter_str,
                        'WFDM_BROWSE',
                        l_icon_name,
                        browse_document_url);

    EXCEPTION
    WHEN OTHERS THEN
       Wf_Core.Context('fnd_document_management',
                       'get_browse_document_url',
                       callback_function);
       RAISE;

END get_browse_document_url;

/*===========================================================================

Function	get_display_document_url

Purpose		Invoke the appropriate document viewer for the selected
		document. This function will show the latest document version
                for the item selected. Most document management systems
		support a wide range of document formats for viewing.
		We will rely on the  document management system to
                display the document in it's native format whenever possible.

============================================================================*/
PROCEDURE get_display_document_url
(username             IN  Varchar2,
 document_identifier  IN  Varchar2,
 show_document_icon   IN  Boolean,
 html_formatting      IN  Boolean,
 display_document_URL OUT NOCOPY Varchar2) IS

l_dm_node_id            Number := 0;
l_document_id           Varchar2(30) := NULL;
l_version               Varchar2(10) := NULL;
l_document_name         Varchar2(240) := NULL;
l_product_id            Number  := 0;
l_product_function_id   Number  := 0;
l_record_num            Number  := 0;
l_node_connect_syntax   Varchar2(240)  := NULL;
l_parameter_str         Varchar2(4000) := NULL;
l_function_syntax       Varchar2(4000)  := NULL;
l_icon_name             Varchar2(40)   := NULL;
l_parameter_list        fnd_document_management.fnd_dm_product_parms_tbl_type;
l_document_attributes   fnd_document_management.fnd_document_attributes;
l_username              VARCHAR2(320) := NULL;
l_dummy                 boolean; -- Bug5161758 HTML injection

BEGIN
    -- Bug5161758 HTML injection
    begin
      l_dummy := wf_core.CheckIllegalChars(username,true);
    exception
      when OTHERS then
        fnd_document_management.error;
        return;
    end;
    l_username := upper(username);

    /*
    ** get all the components of the document attribute
    */
    fnd_document_management.ParseDocInfo(document_identifier,
                                         l_dm_node_id,
                                         l_document_id,
                                         l_version);

    /*
    ** If you're calling this with full html formatting to include the
    ** document title in the link then go get the document title from
    ** the dm system.  This is a very expensive operation and is not
    ** recommended
    */
    IF (html_formatting = TRUE) THEN

       /*
       ** get the document name
       */
       fnd_document_management.get_document_attributes(l_username,
          document_identifier,
          l_document_attributes);

       l_document_name := l_document_attributes.document_name;

    ELSE

       l_document_name := NULL;

    END IF;

    /*
    ** Get the URL prefix for the route to the DM host and the product id
    ** Also get the appropriate syntax for a display function for the vendor
    ** that is servicing this particular node.
    */
    get_function_definition (l_dm_node_id,
                             'get_display_document_url',
                             l_node_connect_syntax,
                             l_product_id,
                             l_function_syntax,
                             l_product_function_id,
                             l_icon_name);

    /*
    ** Go get the parameters for this function for the specific
    ** vendor software that is servicing this particular node
    */
    IF (l_function_syntax IS NOT NULL) THEN

      /*
      ** Get the parameters for the search function
      */
      get_product_parameter_list (l_product_function_id,
 				  l_parameter_list);

      /*
      ** Loop through the parameter list filling in the corresponding
      ** values
      */
      FOR l_record_num IN 1..l_parameter_list.count LOOP

         /*
         ** Determine which argument separator to add
         */
         IF (INSTR(l_parameter_str, '?') > 0 OR
              INSTR(l_function_syntax, '?') > 0) THEN
             l_parameter_str := l_parameter_str || '&';
         ELSE
             l_parameter_str := l_parameter_str || '?';
         END IF;

         IF (l_parameter_list(l_record_num).parameter_name =  'DOCUMENT_ID') THEN
             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 l_document_id;
         ELSIF (l_parameter_list(l_record_num).parameter_name = 'USERNAME') THEN
             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 wfa_html.conv_special_url_chars(l_username); -- Bug5161758 - XSS
         ELSIF (l_parameter_list(l_record_num).parameter_name = 'TICKET') THEN
             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 wfa_html.conv_special_url_chars(
                 fnd_document_management.get_ticket(l_username)); -- Bug5161758 - XSS
         END IF;

      END LOOP;

    END IF;

    /*
    ** Create the proper html syntax for the document function
    */
    create_html_syntax (html_formatting,
                        'get_display_document_url',
                        l_node_connect_syntax,
                        l_function_syntax,
                        l_parameter_str,
                        l_document_name,
                        l_icon_name,
                        display_document_url);


    EXCEPTION
    WHEN OTHERS THEN
       Wf_Core.Context('fnd_document_management',
                       'get_display_document_url',
                       document_identifier);
       RAISE;

END get_display_document_url;

/*===========================================================================

Function	get_original_document_url

Purpose		Invoke the appropriate document viewer for the original version
                of the selected document. The default operation of the DM
                system is to show the latest version of the document that
                was attached to the item.
                We are providing another function here to show the original
                version of the document.
                Most document management systems
		support a wide range of document formats for viewing.
		We will rely on the  document management system to
                display the document in it's native format whenever possible.

============================================================================*/
PROCEDURE get_original_document_url
(username             IN  Varchar2,
 document_identifier  IN  Varchar2,
 show_document_icon   IN  Boolean,
 html_formatting      IN  Boolean,
 original_document_URL OUT NOCOPY Varchar2) IS

l_dm_node_id            Number := 0;
l_document_id           Varchar2(30) := NULL;
l_version               Varchar2(10) := NULL;
l_document_name         Varchar2(240) := NULL;
l_product_id            Number  := 0;
l_product_function_id   Number  := 0;
l_record_num            Number  := 0;
l_node_connect_syntax   Varchar2(240)  := NULL;
l_parameter_str         Varchar2(4000) := NULL;
l_function_syntax       Varchar2(4000)  := NULL;
l_icon_name             Varchar2(40)   := NULL;
l_parameter_list        fnd_document_management.fnd_dm_product_parms_tbl_type;
l_document_attributes   fnd_document_management.fnd_document_attributes;
l_username              VARCHAR2(320) := NULL;
l_dummy                 boolean; -- Bug5161758 HTML injection

BEGIN
    -- Bug5161758 HTML injection
    begin
      l_dummy := wf_core.CheckIllegalChars(username,true);
    exception
      when OTHERS then
        fnd_document_management.error;
        return;
    end;
    l_username := upper(username);

    /*
    ** get all the components of the document attribute
    */
    fnd_document_management.ParseDocInfo(document_identifier,
                                         l_dm_node_id,
                                         l_document_id,
                                         l_version);

    /*
    ** If you're calling this with full html formatting to include the
    ** document title in the link then go get the document title from
    ** the dm system.  This is a very expensive operation and is not
    ** recommended
    */
    IF (html_formatting = TRUE) THEN

       /*
       ** get the document name
       */
       fnd_document_management.get_document_attributes(l_username,
          document_identifier,
          l_document_attributes);

       l_document_name := l_document_attributes.document_name;

    ELSE

       l_document_name := NULL;

    END IF;

    /*
    ** Get the URL prefix for the route to the DM host and the product id
    ** Also get the appropriate syntax for a display function for the vendor
    ** that is servicing this particular node.
    */
    get_function_definition (l_dm_node_id,
                             'get_display_document_url',
                             l_node_connect_syntax,
                             l_product_id,
                             l_function_syntax,
                             l_product_function_id,
                             l_icon_name);

    /*
    ** Go get the parameters for this function for the specific
    ** vendor software that is servicing this particular node
    */
    IF (l_function_syntax IS NOT NULL) THEN

      /*
      ** Get the parameters for the search function
      */
      get_product_parameter_list (l_product_function_id,
 				  l_parameter_list);

      /*
      ** Loop through the parameter list filling in the corresponding
      ** values
      */
      FOR l_record_num IN 1..l_parameter_list.count LOOP

         /*
         ** Determine which argument separator to add
         */

         IF (INSTR(l_parameter_str, '?') > 0 OR
              INSTR(l_function_syntax, '?') > 0) THEN

             l_parameter_str := l_parameter_str || '&';

         ELSE

             l_parameter_str := l_parameter_str || '?';

         END IF;

         /*
         ** The only difference in the syntax from the
         ** get_display_document_url  is to drop the version parameter
         */

         IF (l_parameter_list(l_record_num).parameter_name =  'DOCUMENT_ID') THEN

             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 l_document_id;

         ELSIF (l_parameter_list(l_record_num).parameter_name = 'VERSION') THEN

             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 l_version;

         ELSIF (l_parameter_list(l_record_num).parameter_name = 'USERNAME') THEN

             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 l_username;

         ELSIF (l_parameter_list(l_record_num).parameter_name = 'TICKET') THEN

             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 fnd_document_management.get_ticket(l_username);


         END IF;

      END LOOP;

    END IF;

    /*
    ** Create the proper html syntax for the document function
    */
    create_html_syntax (html_formatting,
                        'get_display_document_url',
                        l_node_connect_syntax,
                        l_function_syntax,
                        l_parameter_str,
                        l_document_name,
                        l_icon_name,
                        original_document_url);


    EXCEPTION
    WHEN OTHERS THEN
       Wf_Core.Context('fnd_document_management',
                       'get_original_document_url',
                       document_identifier);
       RAISE;

END get_original_document_url;

/*===========================================================================

Function	get_fetch_document_url

Purpose		Fetch a copy of a document from a document management system
                and place it on the local system.  Always fetch the latest
                version of the document

============================================================================*/
PROCEDURE get_fetch_document_url
(username               IN  Varchar2,
 document_identifier    IN  Varchar2,
 html_formatting        IN  Boolean,
 fetch_document_URL     OUT NOCOPY Varchar2) IS

l_dm_node_id            Number := 0;
l_document_id           Varchar2(30) := NULL;
l_version               Varchar2(10) := NULL;
l_product_id            Number  := 0;
l_product_function_id   Number  := 0;
l_record_num            Number  := 0;
l_node_connect_syntax   Varchar2(240)  := '';
l_parameter_str         Varchar2(4000) := '';
l_function_syntax       Varchar2(4000)  := '';
l_icon_name             Varchar2(40)   := '';
l_parameter_list        fnd_document_management.fnd_dm_product_parms_tbl_type;
l_username              Varchar2(320) := NULL;
l_dummy                 boolean; -- Bug5161758 HTML injection

BEGIN
    -- Bug5161758 HTML injection
    begin
      l_dummy := wf_core.CheckIllegalChars(username,true);
    exception
      when OTHERS then
        fnd_document_management.error;
        return;
    end;
    l_username := upper(username);

    /*
    ** get all the components of the document attribute
    */
    fnd_document_management.ParseDocInfo(document_identifier,
                                         l_dm_node_id,
                                         l_document_id,
                                         l_version);

    /*
    ** Get the URL prefix for the route to the DM host and the product id
    ** Also get the appropriate syntax for a fetch function for the vendor
    ** that is servicing this particular node.
    */
    get_function_definition (l_dm_node_id,
                             'get_fetch_document_url',
                             l_node_connect_syntax,
                             l_product_id,
                             l_function_syntax,
                             l_product_function_id,
                             l_icon_name);

    /*
    ** Go get the parameters for this function for the specific
    ** vendor software that is servicing this particular node
    */
    IF (l_function_syntax IS NOT NULL) THEN

      /*
      ** Get the parameters for the search function
      */
      get_product_parameter_list (l_product_function_id,
 				  l_parameter_list);

      /*
      ** Loop through the parameter list filling in the corresponding
      ** values
      */
      FOR l_record_num IN 1..l_parameter_list.count LOOP

         /*
         ** Determine which argument separator to add
         */
         IF (INSTR(l_parameter_str, '?') > 0 OR
              INSTR(l_function_syntax, '?') > 0) THEN
             l_parameter_str := l_parameter_str || '&';
         ELSE
             l_parameter_str := l_parameter_str || '?';
         END IF;

         IF (l_parameter_list(l_record_num).parameter_name =  'DOCUMENT_ID') THEN
             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 l_document_id;
         ELSIF (l_parameter_list(l_record_num).parameter_name = 'USERNAME') THEN
             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 l_username;
         ELSIF (l_parameter_list(l_record_num).parameter_name = 'TICKET') THEN
             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 fnd_document_management.get_ticket(l_username);
         END IF;
      END LOOP;
    END IF;

    /*
    ** Create the proper html syntax for the document function
    */
    create_html_syntax (html_formatting,
                        'get_fetch_document_url',
                        l_node_connect_syntax,
                        l_function_syntax,
                        l_parameter_str,
                        'WFDM_FETCH',
                        l_icon_name,
                        fetch_document_url);

    EXCEPTION
    WHEN OTHERS THEN
       Wf_Core.Context('fnd_document_management',
                       'get_fetch_document_url',
                       document_identifier);
       RAISE;

END  get_fetch_document_url;

/*===========================================================================

Function	get_check_out_document_url

Purpose		Lock the document in the DM system so that no other user can
                check in a new revision of the document while you
                hold the lock. This function will also allow you to create
                a local copy of the document on your file system.

============================================================================*/
PROCEDURE get_check_out_document_url
(username               IN  Varchar2,
 document_identifier    IN  Varchar2,
 html_formatting        IN  Boolean,
 check_out_document_URL OUT NOCOPY Varchar2) IS

l_dm_node_id            Number := 0;
l_document_id           Varchar2(30) := NULL;
l_version               Varchar2(10) := NULL;
l_product_id            Number  := 0;
l_product_function_id   Number  := 0;
l_record_num            Number  := 0;
l_node_connect_syntax   Varchar2(240)  := '';
l_display_document_url  Varchar2(2000) := '';
l_function_syntax       Varchar2(4000)  := '';
l_parameter_str         Varchar2(4000) := '';
l_icon_name             Varchar2(40)   := '';
l_parameter_list        fnd_document_management.fnd_dm_product_parms_tbl_type;
l_username              Varchar2(320):= NULL;
l_dummy                 boolean; -- Bug5161758 HTML injection

BEGIN
    -- Bug5161758 HTML injection
    begin
      l_dummy := wf_core.CheckIllegalChars(username,true);
    exception
      when OTHERS then
        fnd_document_management.error;
        return;
    end;
    l_username := upper(username);

    /*
    ** get all the components of the document attribute
    */
    fnd_document_management.ParseDocInfo(document_identifier,
                                         l_dm_node_id,
                                         l_document_id,
                                         l_version);

    /*
    ** Get the URL prefix for the route to the DM host and the product id
    ** Also get the appropriate syntax for a check out function for the
    ** vendor that is servicing this particular node.
    */
    get_function_definition (l_dm_node_id,
                             'get_check_out_document_url',
                             l_node_connect_syntax,
                             l_product_id,
                             l_function_syntax,
                             l_product_function_id,
                             l_icon_name);

    /*
    ** Go get the parameters for this function for the specific
    ** vendor software that is servicing this particular node
    */
    IF (l_function_syntax IS NOT NULL) THEN

      /*
      ** Get the parameters for the search function
      */
      get_product_parameter_list (l_product_function_id,
 				  l_parameter_list);

      /*
      ** Loop through the parameter list filling in the corresponding
      ** values
      */
      FOR l_record_num IN 1..l_parameter_list.count LOOP

         /*
         ** Determine which argument separator to add
         */
         IF (INSTR(l_parameter_str, '?') > 0 OR
              INSTR(l_function_syntax, '?') > 0) THEN
             l_parameter_str := l_parameter_str || '&';
         ELSE
             l_parameter_str := l_parameter_str || '?';
         END IF;

         IF (l_parameter_list(l_record_num).parameter_name =  'DOCUMENT_ID') THEN
             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 l_document_id;
         ELSIF (l_parameter_list(l_record_num).parameter_name =  'CALLBACK') THEN
             fnd_document_management.get_display_document_url (
                 l_username,
                 document_identifier,
                 FALSE,
                 FALSE,
                 l_display_document_url);
             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 wfa_html.conv_special_url_chars(l_display_document_url);
         ELSIF (l_parameter_list(l_record_num).parameter_name = 'USERNAME') THEN
             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 l_username;
         ELSIF (l_parameter_list(l_record_num).parameter_name = 'TICKET') THEN
             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 fnd_document_management.get_ticket(l_username);
         END IF;
      END LOOP;
    END IF;

    /*
    ** Create the proper html syntax for the document function
    */
    create_html_syntax (html_formatting,
                        'get_check_out_document_url',
                        l_node_connect_syntax,
                        l_function_syntax,
                        l_parameter_str,
                        'WFDM_CHECK_OUT',
                        l_icon_name,
                        check_out_document_url);

    EXCEPTION
    WHEN OTHERS THEN
       Wf_Core.Context('fnd_document_management',
                       'get_check_out_document_url',
                       document_identifier);
       RAISE;

END  get_check_out_document_url;

/*===========================================================================

Function	get_check_in_document_url

Purpose		Copy a new version of a file from your local file system
                back into the document management system.  UnLock the
                document in the DM system so that other users can work
                on the document.

============================================================================*/
PROCEDURE get_check_in_document_url
(username               IN  Varchar2,
 document_identifier    IN Varchar2,
 html_formatting        IN Boolean,
 check_in_document_URL  OUT NOCOPY Varchar2) IS

l_dm_node_id            Number := 0;
l_document_id           Varchar2(30) := NULL;
l_version               Varchar2(10) := NULL;
l_product_id            Number  := 0;
l_product_function_id   Number  := 0;
l_record_num            Number  := 0;
l_node_connect_syntax   Varchar2(240)  := '';
l_display_document_url  Varchar2(2000) := '';
l_function_syntax       Varchar2(4000)  := '';
l_parameter_str         Varchar2(4000) := '';
l_icon_name             Varchar2(40)   := '';
l_parameter_list        fnd_document_management.fnd_dm_product_parms_tbl_type;
l_username              Varchar2(320)  := NULL;
l_dummy                 boolean; -- Bug5161758 HTML injection

BEGIN
    -- Bug5161758 HTML injection
    begin
      l_dummy := wf_core.CheckIllegalChars(username,true);
    exception
      when OTHERS then
        fnd_document_management.error;
        return;
    end;
    l_username := upper(username);

    /*
    ** get all the components of the document attribute
    */
    fnd_document_management.ParseDocInfo(document_identifier,
                                         l_dm_node_id,
                                         l_document_id,
                                         l_version);
    /*
    ** Get the URL prefix for the route to the DM host and the product id
    ** Also get the appropriate syntax for a check in function for the vendor
    ** that is servicing this particular node.
    */
    get_function_definition (l_dm_node_id,
                             'get_check_in_document_url',
                             l_node_connect_syntax,
                             l_product_id,
                             l_function_syntax,
                             l_product_function_id,
                             l_icon_name);

    /*
    ** Go get the parameters for this function for the specific
    ** vendor software that is servicing this particular node
    */
    IF (l_function_syntax IS NOT NULL) THEN

      /*
      ** Get the parameters for the search function
      */
      get_product_parameter_list (l_product_function_id,
 				  l_parameter_list);

      /*
      ** Loop through the parameter list filling in the corresponding
      ** values
      */
      FOR l_record_num IN 1..l_parameter_list.count LOOP

         /*
         ** Determine which argument separator to add
         */

         IF (INSTR(l_parameter_str, '?') > 0 OR
              INSTR(l_function_syntax, '?') > 0) THEN

             l_parameter_str := l_parameter_str || '&';

         ELSE

             l_parameter_str := l_parameter_str || '?';

         END IF;

         IF (l_parameter_list(l_record_num).parameter_name =  'DOCUMENT_ID') THEN

             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 l_document_id;


         ELSIF (l_parameter_list(l_record_num).parameter_name =  'CALLBACK') THEN

             fnd_document_management.get_display_document_url (
                 l_username,
                 document_identifier,
                 FALSE,
                 FALSE,
                 l_display_document_url);

             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 wfa_html.conv_special_url_chars(l_display_document_url);

         ELSIF (l_parameter_list(l_record_num).parameter_name = 'USERNAME') THEN

             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 l_username;

         ELSIF (l_parameter_list(l_record_num).parameter_name = 'TICKET') THEN

             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 fnd_document_management.get_ticket(l_username);

         END IF;

      END LOOP;

    END IF;

    /*
    ** Create the proper html syntax for the document function
    */
    create_html_syntax (html_formatting,
                        'get_check_in_document_url',
                        l_node_connect_syntax,
                        l_function_syntax,
                        l_parameter_str,
                        'WFDM_CHECK_IN',
                        l_icon_name,
                        check_in_document_url);

    EXCEPTION
    WHEN OTHERS THEN
       Wf_Core.Context('fnd_document_management',
                       'get_check_in_document_url',
                       document_identifier);
       RAISE;

END  get_check_in_document_url;


/*===========================================================================

Function	get_lock_document_url

Purpose		Lock the document in the DM system so that no other
                user can check in a new revision of the document while
                you hold the lock.

============================================================================*/
PROCEDURE get_lock_document_url
(username               IN  Varchar2,
 document_identifier    IN  Varchar2,
 html_formatting        IN  Boolean,
 lock_document_URL      OUT NOCOPY Varchar2) IS

l_dm_node_id            Number := 0;
l_document_id           Varchar2(30) := NULL;
l_version               Varchar2(10) := NULL;
l_product_id            Number  := 0;
l_product_function_id   Number  := 0;
l_record_num            Number  := 0;
l_node_connect_syntax   Varchar2(240)  := '';
l_display_document_url  Varchar2(2000) := '';
l_function_syntax       Varchar2(4000)  := '';
l_parameter_str         Varchar2(4000) := '';
l_icon_name             Varchar2(40)   := '';
l_parameter_list        fnd_document_management.fnd_dm_product_parms_tbl_type;
l_username              Varchar2(320)  := NULL;
l_dummy                 boolean; -- Bug5161758 HTML injection

BEGIN
    -- Bug5161758 HTML injection
    begin
      l_dummy := wf_core.CheckIllegalChars(username,true);
    exception
      when OTHERS then
        fnd_document_management.error;
        return;
    end;
    l_username := upper(username);

    /*
    ** get all the components of the document attribute
    */
    fnd_document_management.ParseDocInfo(document_identifier,
                                         l_dm_node_id,
                                         l_document_id,
                                         l_version);

    /*
    ** Get the URL prefix for the route to the DM host and the product id
    ** Also get the appropriate syntax for a lock function for the vendor
    ** that is servicing this particular node.
    */
    get_function_definition (l_dm_node_id,
                             'get_lock_document_url',
                             l_node_connect_syntax,
                             l_product_id,
                             l_function_syntax,
                             l_product_function_id,
                             l_icon_name);

    /*
    ** Go get the parameters for this function for the specific
    ** vendor software that is servicing this particular node
    */
    IF (l_function_syntax IS NOT NULL) THEN

      /*
      ** Get the parameters for the search function
      */
      get_product_parameter_list (l_product_function_id,
 				  l_parameter_list);

      /*
      ** Loop through the parameter list filling in the corresponding
      ** values
      */
      FOR l_record_num IN 1..l_parameter_list.count LOOP

         /*
         ** Determine which argument separator to add
         */

         IF (INSTR(l_parameter_str, '?') > 0 OR
              INSTR(l_function_syntax, '?') > 0) THEN

             l_parameter_str := l_parameter_str || '&';

         ELSE

             l_parameter_str := l_parameter_str || '?';

         END IF;

         IF (l_parameter_list(l_record_num).parameter_name =  'DOCUMENT_ID') THEN

             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 l_document_id;


         ELSIF (l_parameter_list(l_record_num).parameter_name =  'CALLBACK') THEN

             fnd_document_management.get_display_document_url (
                 l_username,
                 document_identifier,
                 FALSE,
                 FALSE,
                 l_display_document_url);

             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 wfa_html.conv_special_url_chars(l_display_document_url);

         ELSIF (l_parameter_list(l_record_num).parameter_name = 'USERNAME') THEN

             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 l_username;

         ELSIF (l_parameter_list(l_record_num).parameter_name = 'TICKET') THEN

             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 fnd_document_management.get_ticket(l_username);

         END IF;

      END LOOP;

    END IF;

    /*
    ** Create the proper html syntax for the document function
    */
    create_html_syntax (html_formatting,
                        'get_lock_document_url',
                        l_node_connect_syntax,
                        l_function_syntax,
                        l_parameter_str,
                        'WFDM_LOCK',
                        l_icon_name,
                        lock_document_url);

    EXCEPTION
    WHEN OTHERS THEN
       Wf_Core.Context('fnd_document_management',
                       'get_lock_document_url',
                       document_identifier);
       RAISE;

END  get_lock_document_url;

/*===========================================================================

Function	get_unlock_document_url

Purpose		Unlock the document in the DM system without checking
                in a new version of the document so that other users
                can check in new revisions of the document.

============================================================================*/
PROCEDURE get_unlock_document_url
(username              IN  Varchar2,
 document_identifier   IN  Varchar2,
 html_formatting       IN  Boolean,
 unlock_document_URL   OUT NOCOPY Varchar2) IS

l_dm_node_id            Number := 0;
l_document_id           Varchar2(30) := NULL;
l_version               Varchar2(10) := NULL;
l_product_id            Number  := 0;
l_product_function_id   Number  := 0;
l_record_num            Number  := 0;
l_node_connect_syntax   Varchar2(240)  := '';
l_display_document_url  Varchar2(2000) := '';
l_function_syntax       Varchar2(4000)  := '';
l_parameter_str         Varchar2(4000) := '';
l_icon_name             Varchar2(40)   := '';
l_parameter_list        fnd_document_management.fnd_dm_product_parms_tbl_type;
l_username              Varchar2(320):= NULL;
l_dummy                 boolean; -- Bug5161758 HTML injection

BEGIN
    -- Bug5161758 HTML injection
    begin
      l_dummy := wf_core.CheckIllegalChars(username,true);
    exception
      when OTHERS then
        fnd_document_management.error;
        return;
    end;
    l_username := upper(username);

    /*
    ** get all the components of the document attribute
    */
    fnd_document_management.ParseDocInfo(document_identifier,
                                         l_dm_node_id,
                                         l_document_id,
                                         l_version);

    /*
    ** Get the URL prefix for the route to the DM host and the product id
    ** Also get the appropriate syntax for a unlock function for the vendor
    ** that is servicing this particular node.
    */
    get_function_definition (l_dm_node_id,
                             'get_unlock_document_url',
                             l_node_connect_syntax,
                             l_product_id,
                             l_function_syntax,
                             l_product_function_id,
                             l_icon_name);

    /*
    ** Go get the parameters for this function for the specific
    ** vendor software that is servicing this particular node
    */
    IF (l_function_syntax IS NOT NULL) THEN

      /*
      ** Get the parameters for the search function
      */
      get_product_parameter_list (l_product_function_id,
 				  l_parameter_list);

      /*
      ** Loop through the parameter list filling in the corresponding
      ** values
      */
      FOR l_record_num IN 1..l_parameter_list.count LOOP

         /*
         ** Determine which argument separator to add
         */

         IF (INSTR(l_parameter_str, '?') > 0 OR
              INSTR(l_function_syntax, '?') > 0) THEN

             l_parameter_str := l_parameter_str || '&';

         ELSE

             l_parameter_str := l_parameter_str || '?';

         END IF;

         IF (l_parameter_list(l_record_num).parameter_name =  'DOCUMENT_ID') THEN

             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 l_document_id;


         ELSIF (l_parameter_list(l_record_num).parameter_name =  'CALLBACK') THEN

             fnd_document_management.get_display_document_url (
                 l_username,
                 document_identifier,
                 FALSE,
                 FALSE,
                 l_display_document_url);

             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 wfa_html.conv_special_url_chars(l_display_document_url);

         ELSIF (l_parameter_list(l_record_num).parameter_name = 'USERNAME') THEN

             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 l_username;

         ELSIF (l_parameter_list(l_record_num).parameter_name = 'TICKET') THEN

             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 fnd_document_management.get_ticket(l_username);

         END IF;

      END LOOP;

    END IF;

    /*
    ** Create the proper html syntax for the document function
    */
    create_html_syntax (html_formatting,
                        'get_unlock_document_url',
                        l_node_connect_syntax,
                        l_function_syntax,
                        l_parameter_str,
                        'WFDM_UNLOCK',
                        l_icon_name,
                        unlock_document_url);

    EXCEPTION
    WHEN OTHERS THEN
       Wf_Core.Context('fnd_document_management',
                       'get_unlock_document_url',
                       document_identifier);
       RAISE;

END  get_unlock_document_url;

/*===========================================================================
Function	get_display_history_url

Purpose		Display the file history for the document in the Document
                Management System. Display the document title, type, size,
                whether the document is locked and if so by who, who has
                edited the document and when, etc.

============================================================================*/
PROCEDURE get_display_history_url
(username               IN  Varchar2,
 document_identifier    IN  Varchar2,
 html_formatting 	IN  Boolean,
 display_history_URL 	OUT NOCOPY Varchar2) IS

l_dm_node_id            Number := 0;
l_document_id           Varchar2(30) := NULL;
l_version               Varchar2(10) := NULL;
l_product_id            Number  := 0;
l_product_function_id   Number  := 0;
l_record_num            Number  := 0;
l_node_connect_syntax   Varchar2(240)  := '';
l_display_document_url  Varchar2(2000) := '';
l_function_syntax       Varchar2(4000)  := '';
l_parameter_str         Varchar2(4000) := '';
l_icon_name             Varchar2(40)   := '';
l_parameter_list        fnd_document_management.fnd_dm_product_parms_tbl_type;
l_username              Varchar2(320):= NULL;
l_dummy                 boolean; -- Bug5161758 HTML injection

BEGIN
    -- Bug5161758 HTML injection
    begin
      l_dummy := wf_core.CheckIllegalChars(username,true);
    exception
      when OTHERS then
        fnd_document_management.error;
        return;
    end;
    l_username := upper(username);

    /*
    ** get all the components of the document attribute
    */
    fnd_document_management.ParseDocInfo(document_identifier,
                                         l_dm_node_id,
                                         l_document_id,
                                         l_version);

    /*
    ** Get the URL prefix for the route to the DM host and the product id
    ** Also get the appropriate syntax for a display function for the vendor
    ** that is servicing this particular node.
    */
    get_function_definition (l_dm_node_id,
                             'get_display_history_url',
                             l_node_connect_syntax,
                             l_product_id,
                             l_function_syntax,
                             l_product_function_id,
                             l_icon_name);

    /*
    ** Go get the parameters for this function for the specific
    ** vendor software that is servicing this particular node
    */
    IF (l_function_syntax IS NOT NULL) THEN

      /*
      ** Get the parameters for the search function
      */
      get_product_parameter_list (l_product_function_id,
 				  l_parameter_list);

      /*
      ** Loop through the parameter list filling in the corresponding
      ** values
      */
      FOR l_record_num IN 1..l_parameter_list.count LOOP

         /*
         ** Determine which argument separator to add
         */

         IF (INSTR(l_parameter_str, '?') > 0 OR
              INSTR(l_function_syntax, '?') > 0) THEN

             l_parameter_str := l_parameter_str || '&';

         ELSE

             l_parameter_str := l_parameter_str || '?';

         END IF;

         IF (l_parameter_list(l_record_num).parameter_name =  'DOCUMENT_ID') THEN

             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 l_document_id;


         ELSIF (l_parameter_list(l_record_num).parameter_name =  'CALLBACK') THEN

             fnd_document_management.get_display_document_url (
                 l_username,
                 document_identifier,
                 FALSE,
                 FALSE,
                 l_display_document_url);

             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 wfa_html.conv_special_url_chars(l_display_document_url);

         ELSIF (l_parameter_list(l_record_num).parameter_name = 'USERNAME') THEN

             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 l_username;

         ELSIF (l_parameter_list(l_record_num).parameter_name = 'TICKET') THEN

             l_parameter_str := l_parameter_str ||
                 l_parameter_list(l_record_num).parameter_syntax ||
                 fnd_document_management.get_ticket(l_username);

         END IF;

      END LOOP;

    END IF;

    /*
    ** Create the proper html syntax for the document function
    */
    create_html_syntax (html_formatting,
                        'get_display_history_url',
                        l_node_connect_syntax,
                        l_function_syntax,
                        l_parameter_str,
                        'WFDM_DISPLAY_HISTORY',
                        l_icon_name,
                        display_history_url);

    EXCEPTION
    WHEN OTHERS THEN
       Wf_Core.Context('fnd_document_management',
                       'get_display_history_url',
                       document_identifier);
       RAISE;

END  get_display_history_url;


/*===========================================================================

Function	get_open_dm_display_window

Purpose		Get the javascript function to open a dm window based on
                a url and a window size.  This java script function will
                be used by all the DM display functions to open the
                appropriate DM window.  This function also gives the
                current window a name so that the dm window can call
                back to the javascript functions in the current window.

============================================================================*/
PROCEDURE get_open_dm_display_window IS

BEGIN

   htp.p('<SCRIPT LANGUAGE="JavaScript"> <!-- hide the script''s contents from feeble browsers');

   htp.p(
      'function fnd_open_dm_display_window(url,x,y)
       {
          var attributes=
             "resizable=yes,scrollbars=yes,toolbar=yes,menubar=yes,width="+x+",height="+ y;
          FNDDMwindow = window.open(url, "FNDDMwindow", attributes);

          FNDDMwindow.focus();

          FNDDMwindow.opener = self;

       }'
   );


   htp.p('<!-- done hiding from old browsers --> </SCRIPT>');
   htp.p('<NOSCRIPT>' || WF_CORE.Translate('WFA_NOSCRIPT') || '</NOSCRIPT>');

   EXCEPTION
   WHEN OTHERS THEN
      Wf_Core.Context('fnd_document_management',
                      'get_open_dm_display_window');
      RAISE;

END get_open_dm_display_window;

/*===========================================================================

Function	get_open_dm_attach_window

Purpose		Get the javascript function to open a dm window based on
                a url and a window size.  This java script function will
                be used by all the DM functions to open the appropriate DM
                window when attaching a new document to a business object.
                This function also gives the current window
                a name so that the dm window can call back to the javascript
                functions in the current window.

============================================================================*/
PROCEDURE get_open_dm_attach_window IS

BEGIN

   htp.p('<SCRIPT LANGUAGE="JavaScript"> <!-- hide the script''s contents from feeble browsers');

   htp.p(
      'function fnd_open_dm_attach_window(url,x,y)
       {
          var attributes=
             "location=no,resizable=yes,scrollbars=yes,toolbar=yes,menubar=yes,width="+x+",height="+ y;
          var transport_attr=
             "location=no,resizable=no,scrollbars=no,toolbar=no,menubar=no,width=300,height=100";

          FNDDMwindow = window.open(url, "FNDDMwindow", attributes);

          FNDDMCopywindow = window.open("'||
            wfa_html.base_url||
                '/fnd_document_management.show_transport_message'||
          '", "FNDDMCopywindow", transport_attr);

          FNDDMwindow.focus();

          FNDDMwindow.opener = self;

          FNDDMCopywindow.opener = self;

       }'
   );

   htp.p('<!-- done hiding from old browsers --> </SCRIPT>');
   htp.p('<NOSCRIPT>' || WF_CORE.Translate('WFA_NOSCRIPT') || '</NOSCRIPT>');

   EXCEPTION
   WHEN OTHERS THEN
      Wf_Core.Context('fnd_document_management',
                      'get_open_dm_attach_window');
      RAISE;

END get_open_dm_attach_window;

/*===========================================================================

Function	set_document_id_html

Purpose		Get the javascript function to set the appropriate
                destination field on your html form from the document
                management select function.

============================================================================*/
PROCEDURE set_document_id_html
(
  frame_name IN VARCHAR2,
  form_name IN VARCHAR2,
  document_id_field_name IN VARCHAR2,
  document_name_field_name IN VARCHAR2,
  callback_url     OUT NOCOPY VARCHAR2
) IS

l_attributes         VARCHAR2(1000) := NULL;
l_callback_url       VARCHAR2(5000) := NULL;
l_browser varchar2(400) := owa_util.get_cgi_env('HTTP_USER_AGENT');

BEGIN

  l_attributes :=  '"location=no,resizable=no,scrollbars=no,toolbar=no,menubar=no,'||
                   'width=300,height=100"';

   IF (frame_name is not null) THEN

         l_callback_url := '"'||dm_base_url||
               '/fnd_document_management.set_document_form_fields'||
               '?document_identifier='||
               'DM:-NodeId-:-ObjectId-:-Version-'||
               '^document_name=-ObjectName-'||
               '^document_name_field=top.opener.parent.'||frame_name||
                  '.document.'||
                  form_name||'.'||document_name_field_name||'.value'||
               '^document_id_field=top.opener.parent.'||frame_name||
                  '.document.'||
                  form_name||'.'||document_id_field_name||'.value" TARGET="FNDDMCopywindow"';

   ELSE

         l_callback_url := '"'||dm_base_url||
               '/fnd_document_management.set_document_form_fields'||
               '?document_identifier='||
               'DM:-NodeId-:-ObjectId-:-Version-'||
               '^document_name=-ObjectName-'||
               '^document_name_field=top.opener.parent.document.'||
                  form_name||'.'||document_name_field_name||'.value'||
               '^document_id_field=top.opener.parent.document.'||
                  form_name||'.'||document_id_field_name||'.value" TARGET="FNDDMCopywindow"';


   END IF;

   callback_url := wfa_html.conv_special_url_chars(l_callback_url);

   EXCEPTION
   WHEN OTHERS THEN
      Wf_Core.Context('fnd_document_management',
                      'set_document_id_html',
		      form_name,
		      document_id_field_name,
		      document_name_field_name);
      RAISE;

END set_document_id_html;

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
		       document_info out nocopy varchar2) IS

BEGIN

    document_info := 'DM:'||
                     TO_CHAR(dm_node_id) || ':' ||
                     document_id         || ':' ||
                     version;

END PackDocInfo;

--
-- ParseDocInfo
--   Parse out the document components out of a document type
--   attribute.
--
--   document_info - Concatenated string of characters that includes the
--                   nodeid, document id, version, and
--                   document name in the following format:
--
--                   nodeid:document id:version
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
                       dm_node_id    out nocopy number,
                       document_id   out nocopy varchar2,
		       version       out nocopy varchar2)
is

  colon pls_integer;
  doc_str             varchar2(2000);

begin


    -- Parse DM: from document information
    doc_str := substrb(document_info, 4);

    -- Parse dm_node_id from document information
    colon := instr(doc_str, ':');

    if ((colon <> 0) and (colon < 80)) then

       dm_node_id := to_number(substrb(doc_str, 1, colon-1));

       -- get the document id and name off the rest of the string
       doc_str := substrb(doc_str, colon+1);

    end if;

    -- Parse document_id from document information
    colon := instr(doc_str, ':');

    if ((colon <> 0) and (colon < 80)) then

       document_id := substrb(doc_str, 1, colon-1);

       -- get the document id and name off the rest of the string
       doc_str := substrb(doc_str, colon+1);

    end if;

    -- Parse document id from document information
    colon := instr(doc_str, ':');

    version := substrb(doc_str, colon+1);

exception
    when others then
        raise;

end ParseDocInfo;

/*===========================================================================

Function	create_document_toolbar

Purpose		create the toolbar for checking in/checking out etc.
                documents based on the document identifier

============================================================================*/
PROCEDURE  create_document_toolbar
(
  username            IN VARCHAR2,
  document_identifier IN VARCHAR2) IS

l_dm_node_id            Number := 0;
l_document_id           Varchar2(30) := NULL;
l_version               Varchar2(10) := NULL;
l_username              Varchar2(320) := NULL;
l_document_name         Varchar2(240) := NULL;
c_title                 Varchar2(240)  := NULL;
l_toolbar_color         Varchar2(10)  := '#0000cc';
l_url_syntax            Varchar2(2000) := NULL;
l_document_attributes   fnd_document_management.fnd_document_attributes;
l_dummy                 boolean; -- Bug5161758 HTML injection
BEGIN
    -- Bug5161758 HTML injection
    begin
      l_dummy := wf_core.CheckIllegalChars(username,true);
    exception
      when OTHERS then
        fnd_document_management.error;
        return;
    end;
    l_username := upper(username);

    /*
    ** get all the components of the document attribute
    */
    fnd_document_management.ParseDocInfo(document_identifier,
                                         l_dm_node_id,
                                         l_document_id,
                                         l_version);

    /*
    ** get the document name
    */
    fnd_document_management.get_document_attributes(l_username,
        document_identifier,
        l_document_attributes);

    l_document_name := SUBSTR (l_document_attributes.document_name, 1, 25);

     /*
     ** Create main table for toolbar and icon
     */
     htp.p('<table width=100% Cellpadding=0 Cellspacing=0 border=0> summary=""');


     htp.p('<tr>');

     /*
     ** Put some space on the side
     */
     htp.p('<td width=10 id=""></td>');

     htp.p('<td id="">');

     /*
     ** inner table to define toolbar
     */
     htp.p('<table Cellpadding=0 Cellspacing=0 Border=0 summary="">');

     /*
     ** Left rounded icon for toolbar
     */
     htp.p('<td rowspan=3 id=""><img src='||wfa_html.image_loc||'FNDGTBL.gif alt=""></td>');

     /*
     ** White line on top of toolbar
     */
     htp.p('<td bgcolor=#ffffff height=1 colspan=3 id=""><img src='||wfa_html.image_loc||'FNDDBPXW.gif alt=""></td>');

     /*
     ** Right rounded icon for toolbar
     */
     htp.p('<td rowspan=3 id=""><img src='||wfa_html.image_loc||'FNDGTBR.gif alt=""></td>');

     /*
     ** End the table row for the icons that surround the real toolbar
     */
     htp.p('</tr>');

     /*
     ** Start the table for the real controls
     */
     htp.p('<tr>');

     -- Bug5161758 - XSS
     l_document_name := wf_core.substitutespecialchars(l_document_name);

     /*
     ** Create the page title.
     */
     htp.p('<td bgcolor=#cccccc nowrap height=30 align=middle id="">');

     htp.p('<B>&nbsp;'||l_document_name||'&nbsp;</B>');

     htp.p('</td>');

     /*
     ** Create the dividing line
     */
     htp.p('<td bgcolor=#cccccc nowrap height=30 align=middle id="">');
     htp.p('<img src='||wfa_html.image_loc||'FNDIWDVD.gif border=no align=absmiddle alt="">');

    /*
    ** Create the display document icon control
    */
    fnd_document_management.get_display_document_url (
        l_username,
        document_identifier,
        FALSE,
        FALSE,
        l_url_syntax);

    htp.p('<a href="'||l_url_syntax||'" TARGET="DOCUMENT" onMouseOver="window.status='||''''||
              wf_core.translate('WFDM_DISPLAY')||''''||';return true">'||
              '<img src='||wfa_html.image_loc||'afdsktop.gif height=22 border=no align=absmiddle alt="'||wf_core.translate('WFDM_DISPLAY')||'"></a>');

    /*
    ** Create the display latest version document icon control
    */
    fnd_document_management.get_original_document_url (
        l_username,
        document_identifier,
        FALSE,
        FALSE,
        l_url_syntax);

    htp.p('<a href="'||l_url_syntax||'" TARGET="DOCUMENT" onMouseOver="window.status='||''''||
              wf_core.translate('WFDM_ORIGINAL_VERSION')||''''||';return true">'||
              '<img src='||wfa_html.image_loc||'azprocom.gif border=no align=absmiddle alt="'||wf_core.translate('WFDM_ORIGINAL_VERSION')||'"></a>');

    /*
    ** Create the fetch document icon control
    */
    fnd_document_management.get_fetch_document_url (
        l_username,
        document_identifier,
        FALSE,
        l_url_syntax);

    htp.p('<a href="'||l_url_syntax||'" TARGET="DOCUMENT" onMouseOver="window.status='||''''||
              wf_core.translate('WFDM_FETCH')||''''||';return true">'||
              '<img src='||wfa_html.image_loc||'savecopy.gif border=no align=absmiddle alt="'||wf_core.translate('WFDM_FETCH')||'"></a>');

     /*
     ** Create a dividing line
     */
     htp.p('<img src='||wfa_html.image_loc||'FNDIWDVD.gif border=no align=absmiddle alt="">');

    /*
    ** Create the check out icon control
    */
    fnd_document_management.get_check_out_document_url (
        l_username,
        document_identifier,
        FALSE,
        l_url_syntax);

    htp.p('<a href="'||l_url_syntax||'" TARGET="DOCUMENT" onMouseOver="window.status='||''''||
              wf_core.translate('WFDM_CHECK_OUT')||''''||';return true">'||
              '<img src='||wfa_html.image_loc||'checkout.gif border=no align=absmiddle alt="'||wf_core.translate('WFDM_CHECK_OUT')||'"></a>');

    /*
    ** Create the check in icon control
    */
    fnd_document_management.get_check_in_document_url (
        l_username,
        document_identifier,
        FALSE,
        l_url_syntax);

    htp.p('<a href="'||l_url_syntax||'" TARGET="DOCUMENT" onMouseOver="window.status='||''''||
              wf_core.translate('WFDM_CHECK_IN')||''''||';return true">'||
              '<img src='||wfa_html.image_loc||'checkin.gif border=no align=absmiddle alt="'||wf_core.translate('WFDM_CHECK_IN')||'"></a>');

    /*
    ** Create the unlock icon control
    */
    fnd_document_management.get_unlock_document_url (
        l_username,
        document_identifier,
        FALSE,
        l_url_syntax);

    htp.p('<a href="'||l_url_syntax||'" TARGET="DOCUMENT" onMouseOver="window.status='||''''||
              wf_core.translate('WFDM_UNLOCK')||''''||';return true">'||
              '<img src='||wfa_html.image_loc||'lock_opn.gif height=22  border=no align=absmiddle alt="'||wf_core.translate('WFDM_UNLOCK')||'"></a>');
     /*
     ** Create a dividing line
     */
     htp.p('<img src='||wfa_html.image_loc||'FNDIWDVD.gif border=no align=absmiddle alt="">');

    /*
    ** Create the show history icon
    */
    fnd_document_management.get_display_history_url (
        l_username,
        document_identifier,
        FALSE,
        l_url_syntax);

    htp.p('<a href="'||l_url_syntax||'" TARGET="DOCUMENT" onMouseOver="window.status='||''''||
              wf_core.translate('WFDM_DISPLAY_HISTORY')||''''||';return true">'||
              '<img src='||wfa_html.image_loc||'FNDIINFO.gif height=22 border=no align=absmiddle alt="'||wf_core.translate('WFDM_DISPLAY_HISTORY')||'"></a>');

     htp.p('<img src='||wfa_html.image_loc||'FNDIWDVD.gif border=no align=absmiddle alt="">');

     /*
     ** Create the help icon
     */
     htp.p('<a href="javascript:help_window()" onMouseOver="window.status='||
           ''''||wf_core.translate('WFMON_HELP')||''''||
           ';return true"><img src='||wfa_html.image_loc||'FNDIHELP.gif border=no align=absmiddle alt="'||wf_core.translate('WFMON_HELP')||'"></a></td>');
     htp.p('</tr>');

     /*
     ** Create the black border under the toolbar and close the icon table
     */
     htp.p('<tr>');
     htp.p('<td bgcolor=#666666 height=1 colspan=3 id=""><img src='||wfa_html.image_loc||'FNDDBPXB.gif alt=""></td></tr></table>');

     /*
     ** Close the toolbar table data
     */
     htp.p('</td>');

     /*
     ** Create the logo and close the toolbar and logo table
     */
     htp.p('<td rowspan=5 width=100% align=right><img src='||wfa_html.image_loc||'WFLOGO.gif alt=""></td></tr></table>');


exception
    when others then
       wf_core.context('fnd_document_management',
                       'create_document_toolbar',
                       document_identifier);
       raise;

end create_document_toolbar;



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
 launch_attach_URL    OUT NOCOPY Varchar2) IS

l_product_id       NUMBER;
l_dm_node_id       NUMBER;
l_username         Varchar2(320);   -- Username to query
l_dm_node_name     Varchar2(240);
l_attach_url       VARCHAR2(4000);
l_browser           varchar2(400);
l_callback_function VARCHAR2(4000);
l_dummy                 boolean; -- Bug5161758 HTML injection

BEGIN

    /*
    ** The forms attachments interface calls this same function to
    ** get the proper url to attach a document to a business object.
    ** Since the forms launch process is not within a browser the
    ** owa_util variables will not be available when this string
    ** gets created.  We check here whether your calling this from
    ** a web interface (the display_icon parameter should be changed
    ** to html_interface) or a forms interface.
    */
    IF (display_icon = TRUE) THEN

       l_browser := owa_util.get_cgi_env('HTTP_USER_AGENT');

    ELSE

       l_browser := 'NETSCAPE';

    END IF;

    /*
    ** Get the home node id for this user. If that home is an Internet
    ** Documents home based on
    ** the product id = 1 then this is an Internet Documents install
    ** We do not display the multiframe window in this case with the
    ** control bar on top.  Internet documents has their own toolbar and
    ** has their own mechanism for controlling the DM options.
    */
    -- Bug5161758 HTML injection
    begin
      l_dummy := wf_core.CheckIllegalChars(username,true);
    exception
      when OTHERS then
        fnd_document_management.error;
        return;
    end;
    l_username := upper(username);

    -- get the document management home node information
    fnd_document_management.get_dm_home (l_username, l_dm_node_id, l_dm_node_name);

    /*
    ** get the product that is installed for that dm node
    */
    SELECT MAX(PRODUCT_ID)
    INTO   l_product_id
    FROM   fnd_dm_nodes
    WHERE  node_id = l_dm_node_id;

    /*
    ** get all the components of the document anchor
    */
    IF (display_icon = FALSE) THEN

       /*
       ** If the product id = 1 then this is an Internet Documents install
       ** We do not display the multiframe window in this case with the
       ** control bar on top.  Internet documents has their own toolbar and
       ** has their own mechanism for controlling the DM options.
       */
       IF (l_product_id = 1) THEN

          /*
          ** Get the HTML text for displaying the document
          */
          fnd_document_management.get_search_document_url (
             username,
             callback_function,
             FALSE,
             l_attach_URL);

          /*
          ** Replace the NodeId token with the current dm home node id for
          ** this user
          */
          launch_attach_URL := REPLACE(l_attach_URL, '-NodeId-',
                  TO_CHAR(l_dm_node_id));


       ELSE

          launch_attach_URL :=
             dm_base_url||
             '/fnd_document_management.create_attach_document_url?'||
             'username='||username||
             '&callback_function='||
             callback_function;

       END IF;

    ELSE

       /*
       ** If the product id = 1 then this is an Internet Documents install
       ** We do not display the multiframe window in this case with the
       ** control bar on top.  Internet documents has their own toolbar and
       ** has their own mechanism for controlling the DM options.
       */
       IF (l_product_id = 1) THEN

          /*
          ** This is a total hack but it must be done for now for simplicity of
          ** the interface.  The response notification frame is called bottom.
          ** This does not exist in the javascript object hierarchy when
          ** executing an onload event when creating a new document in the
          ** DM system using Netscape.  So we must check for this very
          ** special case and
          ** remove bottom from the hierarchy.  This could be an issue for
          ** any UI that uses our attach interface when the field is in a frame.
          ** This same REPLACE function is in the  get_search_document_url but
          ** since we always start at the search screen with Inter Docs we
          ** need the same replacement here.
          */
          IF (instr(l_browser, 'MSIE') = 0) then

             l_callback_function := REPLACE(callback_function,
                                            'opener.bottom.document',
                                            'opener.document');

          ELSE

            l_callback_function := callback_function;

          END IF;

          /*
          ** Get the HTML text for displaying the document
          */
          fnd_document_management.get_search_document_url (
             username,
             l_callback_function,
             FALSE,
             l_attach_URL);

          /*
          ** Replace the NodeId token with the current dm home node id for
          ** this user
          */
          l_attach_URL := REPLACE(l_attach_URL, '-NodeId-',
                  TO_CHAR(l_dm_node_id));

          /*
          ** Get the HTML text for displaying the document
          */
          launch_attach_URL :=
             '<A HREF="javascript:fnd_open_dm_attach_window(' || '''' ||
             l_attach_url||
             '''' ||
             ', 700, 600)">'||
             '<IMG SRC="'||wfa_html.image_loc||'afattach.gif" BORDER=no alt="'
             || WF_CORE.Translate('WFITD_ATTACH') || '">'||
             '</A>';
       ELSE

          /*
          ** We need need to fetch URL prefix from WF_WEB_AGENT in wf_resources
          ** since this function gets called from the forms environment
          ** which doesn't know anything about the cgi variables.
          */
          launch_attach_URL :=
             '<A HREF="javascript:fnd_open_dm_attach_window(' || '''' ||
	     dm_base_url||
             '/fnd_document_management.create_attach_document_url?'||
             'username='||username||
             '&callback_function='||callback_function||
             '''' ||
             ', 700, 600)">'||
             '<IMG SRC="'||wfa_html.image_loc||'afattach.gif" BORDER=no alt="'
             || WF_CORE.Translate('WFITD_ATTACH') || '">'||
             ' </A>';

       END IF;

    END IF;

    EXCEPTION
    WHEN OTHERS THEN
       Wf_Core.Context('fnd_document_management',
                       'get_launch_attach_url',
                       callback_function);
       RAISE;

END get_launch_attach_url;

/*===========================================================================

Function	create_display_document_url

Purpose		Launches the toolbar in one frame for the document
                operations and then creates another frame to display
                the document.

============================================================================*/
PROCEDURE create_attach_document_url
(username           IN     Varchar2,
 callback_function  IN     Varchar2) IS

l_username          Varchar2 (320);
l_document_url      Varchar2 (4000);
l_dm_node_id        Number;         -- Document Management Home preference
l_dm_node_name      Varchar2(240);
l_callback_function Varchar2 (2000);
l_dummy                 boolean; -- Bug5161758 HTML injection

BEGIN
  -- Bug5161758 HTML injection / XSS
  begin
    l_dummy := wf_core.CheckIllegalChars(username,true);
  exception
    when OTHERS then
      fnd_document_management.error;
      return;
  end;
  l_username := upper(username);

  -- get the document management home node information
  fnd_document_management.get_dm_home (l_username, l_dm_node_id, l_dm_node_name);

  -- If no document nodes are available then show an error message
  IF (l_dm_node_id IS NULL) THEN

      htp.htmlOpen;
      htp.headOpen;
      htp.title(wf_core.translate('WF_WORKFLOW_TITLE'));
      htp.headClose;

      htp.p ('<BODY bgcolor=#cccccc>');
      htp.tableOpen(cattributes=>'summary=""');
      htp.tableRowOpen;

      htp.tabledata('<IMG SRC="'||wfa_html.image_loc||'prohibit.gif" alt="' ||
                    WF_CORE.Translate('WFDM_NO_NODES') || '">');
      htp.tabledata('<B>'||wf_core.translate('WFDM_NO_NODES')||'</B>');

      htp.tableRowClose;
      htp.tableClose;
      htp.bodyClose;
      htp.htmlclose;
      return;

  END IF;

  -- Check to see if the callback function special url characters have been
  -- converted.  If they have not then convert.
  -- Bug5161758 - XSS - Double encoding already taken care of,
  --   for Apps we need to use encode_url instead
  l_callback_function := wfa_html.encode_url(callback_function);
  l_dm_node_name := SUBSTR (l_dm_node_name , 1, 30);

  htp.htmlOpen;
  htp.headOpen;
  htp.title(l_dm_node_name);
  htp.headClose;

  /*
  ** Create the top header frameset and the bottom summary/detail frameset
  */

  htp.p ('<FRAMESET ROWS="10%,90%" BORDER=0 LONGDESC="'||
          owa_util.get_owa_service_path ||
          'wfa_html.LongDesc?p_token=WFDM_LONGDESC">');

  /*
  ** Create the header frame
  */
  htp.p ('<FRAME NAME=CONTROLS '||
         'SRC='||
         dm_base_url ||
         '/fnd_document_management.create_attach_toolbar?'||
         'username='||username||
         '&callback_function='||l_callback_function||
         ' MARGINHEIGHT=10 MARGINWIDTH=10 '||
         'SCROLLING="NO" NORESIZE FRAMEBORDER=YES LONGDESC="'||
          owa_util.get_owa_service_path ||
          'wfa_html.LongDesc?p_token=WFDM_LONGDESC">');

  /*
  ** Replace the NodeId token with the current dm home node id for
  ** this user
  */
  l_callback_function := REPLACE(l_callback_function, '-NodeId-',
       TO_CHAR(l_dm_node_id));

   /*
   ** Get the HTML text for displaying the document
   */
   fnd_document_management.get_search_document_url (
      username,
      l_callback_function,
      FALSE,
      l_document_url);

   /*
   ** THis is a bit of a cludge for opentext to remove the second parent
   ** on the callback when you are doing a search.
   */
   htp.p ('<FRAME NAME=DOCUMENT '||
          'SRC='||
           REPLACE (l_document_url,
                    '.opener.parent.parent.opener.',
                    '.opener.parent.')||
           ' MARGINHEIGHT=10 MARGINWIDTH=10 '||
           'NORESIZE SCROLLING="YES" FRAMEBORDER=NO LONGDESC="'||
          owa_util.get_owa_service_path ||
          'wfa_html.LongDesc?p_token=WFDM_LONGDESC">');

   /*
   ** Close the summary/details frameset
   */
   htp.p ('</FRAMESET>');

   EXCEPTION
   WHEN OTHERS THEN
       Wf_Core.Context('fnd_document_management',
                       'create_attach_document_url',
                       callback_function);
       RAISE;

END create_attach_document_url;


/*===========================================================================

Function	create_attach_toolbar

Purpose		create the toolbar for attaching a document to a business
                object

============================================================================*/
PROCEDURE  create_attach_toolbar
(
  username          IN VARCHAR2,
  callback_function IN VARCHAR2) IS

c_title                 Varchar2(240)  := NULL;
l_toolbar_color         Varchar2(10)  := '#0000cc';
l_username              Varchar2(320);   -- Username to query
l_dm_node_id            Number;         -- Document Management Home preference
l_dm_node_name          Varchar2(240);
l_callback_function     Varchar2(2000);
l_url_syntax            Varchar2(4000) := NULL;
l_dummy                 boolean; -- Bug5161758 HTML injection

BEGIN
    -- Bug5161758 HTML injection / XSS
    begin
      l_dummy := wf_core.CheckIllegalChars(username,true);
    exception
      when OTHERS then
        fnd_document_management.error;
        return;
    end;
    l_username := upper(username);

    -- get the document management home node information
    fnd_document_management.get_dm_home (l_username, l_dm_node_id, l_dm_node_name);

    l_dm_node_name := SUBSTR (l_dm_node_name , 1, 30);

     /*
     ** Create main table for toolbar and icon
     */
     htp.p('<table width=100% Cellpadding=0 Cellspacing=0 border=0 summary="">');


     htp.p('<tr>');

     /*
     ** Put some space on the side
     */
     htp.p('<td width=10 id=""></td>');

     htp.p('<td id="">');

     /*
     ** inner table to define toolbar
     */
     htp.p('<table Cellpadding=0 Cellspacing=0 Border=0 summary="">');

     /*
     ** Left rounded icon for toolbar
     */
     htp.p('<td rowspan=3><img src='||wfa_html.image_loc||'FNDGTBL.gif alt=""></td>');

     /*
     ** White line on top of toolbar
     */
     htp.p('<td bgcolor=#ffffff height=1 colspan=3 id=""><img src='||wfa_html.image_loc||'FNDDBPXW.gif alt=""></td>');

     /*
     ** Right rounded icon for toolbar
     */
     htp.p('<td rowspan=3 id=""><img src='||wfa_html.image_loc||'FNDGTBR.gif alt=""></td>');

     /*
     ** End the table row for the icons that surround the real toolbar
     */
     htp.p('</tr>');

     /*
     ** Start the table for the real controls
     */
     htp.p('<tr>');

     /*
     ** Always create the home icon
     */
     htp.p('<td bgcolor=#cccccc nowrap height=30 align=middle id="">');

     htp.p('<a href="'||dm_base_url||
                   '/fnd_document_management.choose_home?'||
                   'username='||username||
                   '&callback='||
                   wfa_html.conv_special_url_chars(callback_function)||'"'||
                   '" TARGET="DOCUMENT" onMouseOver="window.status='||''''||
              wf_core.translate('WFDM_HOME')||''''||';return true">'||
              '<img src='||wfa_html.image_loc||'wpreload.gif border=no align=middle alt="'||wf_core.translate('WFDM_HOME')||'"></a>');

     htp.p('<img src='||wfa_html.image_loc||'FNDIWDVD.gif align=absmiddle alt="">');

     htp.p('</td>');

     /*
     ** Create the page title.
     */
     htp.p('<td bgcolor=#cccccc nowrap height=30 align=middle id="">');

     htp.p('<B>&nbsp;'||l_dm_node_name||'&nbsp;</B>');

     htp.p('</td>');

     /*
     ** Create the dividing line
     */
     htp.p('<td bgcolor=#cccccc nowrap height=30 align=middle id="">');
     htp.p('<img src='||wfa_html.image_loc||'FNDIWDVD.gif border=no align=absmiddle alt="">');

    /*
    ** Update the node id token for the search add and browse icons
    ** so they point at the current node.  You don't want to replace it
    ** for the change home icon since you want to preserve the NodeId
    ** token syntax
    */
    l_callback_function := REPLACE(callback_function, '-NodeId-',
       TO_CHAR(l_dm_node_id));

    /*
    ** Create the search document icon control
    */
    fnd_document_management.get_search_document_url (
        username,
        wfa_html.conv_special_url_chars(l_callback_function),
        FALSE,
        l_url_syntax);

    htp.p('<a href="'||
           REPLACE (l_url_syntax,
                    '.opener.parent.parent.opener.',
                    '.opener.parent.')||
            '" TARGET="DOCUMENT" onMouseOver="window.status='||''''||
              wf_core.translate('WFDM_SEARCH')||''''||';return true">'||
              '<img src='||wfa_html.image_loc||'affind.gif border=no align=absmiddle alt="'||wf_core.translate('WFDM_SEARCH')||'"></a>');

    /*
    ** Create the add document icon control
    */
    fnd_document_management.get_create_document_url (
        username,
        wfa_html.conv_special_url_chars(l_callback_function),
        FALSE,
        l_url_syntax);

    htp.p('<a href="'||l_url_syntax||'" TARGET="DOCUMENT" onMouseOver="window.status='||''''||
              wf_core.translate('WFDM_CREATE')||''''||';return true">'||
              '<img src='||wfa_html.image_loc||'affldnew.gif border=no align=absmiddle alt="'||wf_core.translate('WFDM_CREATE')||'"></a>');

    /*
    ** Create the browse icon control
    */
    fnd_document_management.get_browse_document_url (
        username,
        wfa_html.conv_special_url_chars(l_callback_function),
        FALSE,
        l_url_syntax);

    htp.p('<a href="'||l_url_syntax||'" TARGET="DOCUMENT" onMouseOver="window.status='||''''||
              wf_core.translate('WFDM_BROWSE')||''''||';return true">'||
              '<img src='||wfa_html.image_loc||'FNDCATOF.gif border=no align=absmiddle alt="'||wf_core.translate('WFDM_BROWSE')||'"></a>');

        htp.p('<img src='||wfa_html.image_loc||'FNDIWDVD.gif border=no align=absmiddle alt="">');

     /*
     ** Create the help icon
     */
     htp.p('<a href="javascript:help_window()" onMouseOver="window.status='||
           ''''||wf_core.translate('WFMON_HELP_DETAILS')||''''||
           ';return true"><img src='||wfa_html.image_loc||'FNDIHELP.gif border=no align=absmiddle alt="'||wf_core.translate('WFMON_HELP_DETAILS')||'"></a></td>');
     htp.p('</tr>');

     /*
     ** Create the black border under the toolbar and close the icon table
     */
     htp.p('<tr>');
     htp.p('<td bgcolor=#666666 height=1 colspan=3 id=""><img src='||wfa_html.image_loc||'FNDDBPXB.gif alt=""></td></tr></table>');

     /*
     ** Close the toolbar table data
     */
     htp.p('</td>');

     /*
     ** Create the logo and close the toolbar and logo table
     */
     htp.p('<td rowspan=5 width=100% align=right id=""><img src='||wfa_html.image_loc||'WFLOGO.gif alt=""></td></tr></table>');


exception
    when others then
       wf_core.context('fnd_document_management',
                       'create_attach_toolbar',
                       callback_function);
       raise;

end create_attach_toolbar;

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
dm_node_name OUT NOCOPY VARCHAR2) IS

l_dm_node_id NUMBER := NULL;
l_dummy                 boolean; -- Bug5161758 HTML injection
BEGIN
  -- Bug5161758 HTML injection
  begin
    l_dummy := wf_core.CheckIllegalChars(username,true);
  exception
    when OTHERS then
      fnd_document_management.error;
      return;
  end;

  /*
  ** Check for the user default value
  */
  l_dm_node_id := TO_NUMBER(fnd_preference.get (username, 'WF', 'DMHOME'));

  /*
  ** If there was no user default then try to get the system default
  */
  IF (l_dm_node_id IS NULL) THEN

     l_dm_node_id := TO_NUMBER(fnd_preference.get ('-WF_DEFAULT-', 'WF', 'DMHOME'));

  END IF;

  /*
  ** If there was no system default then get the first node in the list
  */
  IF (l_dm_node_id IS NULL) THEN

     /*
     ** Make sure to check for no data found in case there are no
     ** nodes defined.
     */
     BEGIN

        SELECT MAX(node_id)
        INTO   l_dm_node_id
        FROM   fnd_dm_nodes;

     EXCEPTION
        /*
        ** If there are no rows defined then set the output variables
        ** to null
        */
        WHEN NO_DATA_FOUND THEN
           l_dm_node_id := NULL;
           dm_node_id := NULL;
           dm_node_name := NULL;

        WHEN OTHERS THEN
           RAISE;

     END;

  END IF;

  /*
  ** If you have the node id then populate the node name and node id
  ** output variables
  */
  IF (l_dm_node_id IS NOT NULL) THEN

     BEGIN
     /*
     ** Make sure the node hasn't been deleted since the preference
     ** was created by having a no data found exception handler.
     */
     SELECT node_id, node_name
     INTO   dm_node_id, dm_node_name
     FROM   fnd_dm_nodes
     WHERE  node_id = l_dm_node_id;

     EXCEPTION
        /*
        ** If there are no rows defined then set the output variables
        ** to null
        */
        WHEN NO_DATA_FOUND THEN
           l_dm_node_id := NULL;
           dm_node_id := NULL;
           dm_node_name := NULL;
        WHEN OTHERS THEN
           RAISE;

      END;

  END IF;

exception
    when others then
       wf_core.context('fnd_document_management',
                       'get_dm_home',
                       username);
       raise;

end get_dm_home;

/*===========================================================================

Function	set_dm_home

Purpose		set the document management home preference for a given
                user.

============================================================================*/
procedure set_dm_home (
username     IN  VARCHAR2,
dm_node_id   IN  VARCHAR2) IS
l_dummy                 boolean; -- Bug5161758 HTML injection

BEGIN
  -- Bug5161758 HTML injection
  begin
    l_dummy := wf_core.CheckIllegalChars(username,true);
  exception
    when OTHERS then
      fnd_document_management.error;
      return;
  end;
  /*
  ** Set the user default value
  */
  fnd_preference.put (username, 'WF', 'DMHOME', dm_node_id);

exception
    when others then
       wf_core.context('fnd_document_management',
                       'set_dm_home',
                       username,
                       dm_node_id);
       raise;

end set_dm_home;

/*===========================================================================

Function	set_dm_home_html

Purpose		set the document management home preference for a given
                user throught the html interface

============================================================================*/
procedure set_dm_home_html (
dm_node_id   IN  VARCHAR2,
username     IN  VARCHAR2,
callback     IN  VARCHAR2) IS

l_product_id NUMBER;
l_username   VARCHAR2(320);
l_attach_URL VARCHAR2(4000);
l_dummy      boolean; -- Bug5161758 HTML injection

BEGIN

   -- Bug5161758 HTML injection
   begin
     l_dummy := wf_core.CheckIllegalChars(username,true);
   exception
     when OTHERS then
       fnd_document_management.error;
       return;
   end;
   l_username := upper(username);

   /*
   ** Set the user default value
   */
   fnd_document_management.set_dm_home (l_username, dm_node_id);

   /*
   ** get the product that is installed for that dm node
   */
   SELECT MAX(PRODUCT_ID)
   INTO   l_product_id
   FROM   fnd_dm_nodes
   WHERE  node_id = TO_NUMBER(dm_node_id);

   IF (l_product_id = 1) THEN

       /*
       ** Get the HTML text for displaying the document
       */
       fnd_document_management.get_search_document_url (
          username,
          wfa_html.conv_special_url_chars(callback),
          FALSE,
          l_attach_URL);

       /*
       ** Replace the NodeId token with the current dm home node id for
       ** this user
       */
       l_attach_URL := REPLACE(l_attach_URL, '-NodeId-',
               dm_node_id);

       -- use owa_util.redirect_url to redirect the URL to the home page
       owa_util.redirect_url(curl=>l_attach_URL, bclose_header=>TRUE);

   ELSE

      -- use owa_util.redirect_url to redirect the URL to the home page
      owa_util.redirect_url(curl=>dm_base_url ||
       	                 '/fnd_document_management.create_attach_document_url'||
                         '?username='||l_username||
                         '&callback_function='||
                         wfa_html.conv_special_url_chars(callback),
   		         bclose_header=>TRUE);

    END IF;

exception
    when others then
       wf_core.context('fnd_document_management',
                       'set_dm_home_html',
                       dm_node_id, username, callback);
       raise;

end set_dm_home_html;


--
-- Dm_Nodes_Display
--   Produce list of dm_nodes
--
procedure Dm_Nodes_Display
is
  username varchar2(320);   -- Username to query
  admin_role varchar2(320); -- Role for admin mode
  admin_mode varchar2(1) := 'N';
  realname varchar2(360);   -- Display name of username
  s0 varchar2(2000);       -- Dummy
  l_error_msg varchar2(240);
  l_url                varchar2(240);
  l_media              varchar2(240) := wfa_html.image_loc;
  l_icon               varchar2(40);
  l_text               varchar2(240);
  l_onmouseover        varchar2(240);

  cursor nodes_cursor is
    select dmn.node_id,
           dmn.node_name,
           dmn.node_description,
           dmn.connect_syntax,
           dmn.product_id,
           dmp.product_name,
           dmp.vendor_name,
           dmp.version
    from fnd_dm_nodes dmn, fnd_dm_products dmp
    where dmn.product_id = dmp.product_id;

  rowcount number;
  att_tvalue varchar2(2000) default null;
begin

  -- Check current user has admin authority
  wfa_sec.GetSession(username);
  username := upper(username);
  wf_directory.GetRoleInfo(username, realname, s0, s0, s0, s0);

  admin_role := wf_core.translate('WF_ADMIN_ROLE');
  if (admin_role = '*' or
     Wf_Directory.IsPerformer(username, admin_role)) then
         admin_mode := 'Y';
  else

     l_error_msg := wf_core.translate('WFPREF_INVALID_ADMIN');

  end if;

  -- Set page title
  htp.htmlOpen;
  htp.headOpen;
  htp.p('<BASE TARGET="_top">');
  htp.title(wf_core.translate('WFDM_NODES_TITLE'));
  wfa_html.create_help_function('wf/links/dmr.htm?DMREP');
  htp.headClose;
  wfa_sec.Header(FALSE, '',wf_core.translate('WFDM_NODES_TITLE'), FALSE);
  htp.br;

  IF (admin_mode = 'N') THEN

     htp.center(htf.bold(l_error_msg));
     return;

  END IF;

  -- Column headers
  htp.tableOpen('border=1 cellpadding=3 bgcolor=white width="100%" summary=""');
  htp.tableRowOpen(cattributes=>'bgcolor=#006699');

  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
		  wf_core.translate('NAME')||'</font>',
		  calign=>'Center', cattributes=>'id="t_name"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
		  wf_core.translate('DESCRIPTION')||'</font>',
		  calign=>'Center', cattributes=>'id="t_node_description"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'
                  || wf_core.translate('WFDM_WEB_AGENT')||'</font>',
		  calign=>'Center', cattributes=>'id="t_connect_syntax"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
		  wf_core.translate('PRODUCT')||'</font>',
		  calign=>'Center', cattributes=>'id="t_product_name"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
		  wf_core.translate('VENDOR')||'</font>',
		  calign=>'Center', cattributes=>'id="t_vendor_name"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
		  wf_core.translate('VERSION')||'</font>',
		  calign=>'Center', cattributes=>'id="t_version"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
		  wf_core.translate('WFDM_NODE_ID')||'</font>',
		  calign=>'Center', cattributes=>'id="t_node_id"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
		  wf_core.translate('DELETE')||'</font>',
		  calign=>'Center', cattributes=>'id="t_delete"');
  htp.tableRowClose;
  htp.tableRowOpen;
  htp.tableRowClose;

  -- Show all nodes
  for nodes in nodes_cursor loop

    htp.tableRowOpen(null, 'TOP');

    -- Bug5161758 - XSS
    htp.tableData(htf.anchor2(
                    curl=>wfa_html.base_url||
                      '/fnd_document_management.dm_nodes_edit?p_node_id='||
                      to_char(nodes.node_id),
                  ctext=>wf_core.substitutespecialchars(nodes.node_name),
                  ctarget=>'_top'),
                  'Left', cattributes=>'headers="t_name"');
    htp.tableData(wf_core.substitutespecialchars(nodes.node_description),
                  'left',
                  cattributes=>'headers="t_node_description"');
    htp.tableData(wf_core.substitutespecialchars(nodes.connect_syntax),
                  'left',
                  cattributes=>'headers="t_connect_syntax"');
    htp.tableData(wf_core.substitutespecialchars(nodes.product_name),
                  'left',
                  cattributes=>'headers="t_product_name"');
    htp.tableData(wf_core.substitutespecialchars(nodes.vendor_name),
                  'left',
                  cattributes=>'headers="t_vendor_name"');
    htp.tableData(wf_core.substitutespecialchars(nodes.version),
                  'left',
                  cattributes=>'headers="t_version"');
    htp.tableData(wf_core.substitutespecialchars(nodes.node_id), 'left',
                  cattributes=>'headers="t_node_id"');

    htp.tableData(htf.anchor2(curl=>wfa_html.base_url||
                                  '/fnd_document_management.dm_nodes_confirm_delete?p_node_id='||
                                  wf_core.substitutespecialchars(nodes.node_id),
                              ctext=>'<IMG SRC="'||wfa_html.image_loc||'FNDIDELR.gif" BORDER=0 alt="' || WF_CORE.Translate('DELETE') || '">'),
                              'center', cattributes=>'valign="MIDDLE" headers="t_delete"');

  end loop;

  htp.tableclose;

  htp.br;

  htp.tableopen(calign=>'CENTER', cattributes=>'summary=""');

  --Add new node Button
  htp.tableRowOpen;

  l_url         := wfa_html.base_url||'/fnd_document_management.dm_nodes_edit';
  l_icon        := 'FNDJLFOK.gif';
  l_text        := wf_core.translate ('WFDM_CREATE');
  l_onmouseover := wf_core.translate ('WFDM_CREATE');

  htp.p('<TD id="">');

  wf_pref.create_reg_button (l_url, l_onmouseover, l_media, l_icon, l_text);

  htp.p('</TD>');

  htp.tableRowClose;

  htp.tableclose;

  wfa_sec.Footer;
  htp.htmlClose;

exception
  when others then
    wf_core.context('FND_DOCUMENT_MANAGEMENT', 'Dm_Nodes_Display');
    fnd_document_management.error;
end Dm_Nodes_Display;


procedure Dm_Nodes_Edit (
p_node_id   IN VARCHAR2
) IS

BEGIN
 null;
exception
  when others then
    wf_core.context('FND_DOCUMENT_MANAGEMENT', 'Dm_Nodes_edit');
    fnd_document_management.error;

END Dm_Nodes_Edit;


procedure Dm_Nodes_Update (
p_node_id            IN VARCHAR2   ,
p_node_name          IN VARCHAR2   ,
p_node_description   IN VARCHAR2   ,
p_connect_syntax     IN VARCHAR2   ,
p_product_id         IN VARCHAR2   ,
p_product_name       IN VARCHAR2
) IS

BEGIN
  null;
exception
  when others then
    wf_core.context('FND_DOCUMENT_MANAGEMENT', 'Dm_Nodes_update');
    fnd_document_management.error;

END Dm_Nodes_Update;


procedure choose_home (username IN VARCHAR2 ,
                       callback IN VARCHAR2 )

IS

  l_username    varchar2(320);   -- Username to query
  realname      varchar2(360);   -- Display name of username
  admin_role    varchar2(320);   -- Role for admin mode
  admin_mode    varchar2(1);    -- Does user have admin privledges
  s0            varchar2(2000);
  dm_node_id    number;         -- Document Management Home preference
  dm_node_name  varchar2(240);
  l_checked      varchar2(1);
  l_url         varchar2(240);
  l_media       varchar2(240) := wfa_html.image_loc;
  l_icon        varchar2(30) := 'FNDILOV.gif';
  l_text        varchar2(240) := '';
  l_onmouseover varchar2(240) := wf_core.translate ('WFPREF_LOV');
  l_error_msg varchar2(2000) := null;
  l_dummy       boolean; -- Bug5161758 HTML injection
  l_callback    varchar2(2000); -- Bug5161758 XSS

  cursor nodes_cursor is
    select dmn.node_id,
           dmn.node_name,
           dmn.node_description,
           dmn.connect_syntax,
           dmn.product_id,
           dmp.product_name,
           dmp.vendor_name,
           dmp.version
    from fnd_dm_nodes dmn, fnd_dm_products dmp
    where dmn.product_id = dmp.product_id;

begin

  -- Check session and current user
  -- Bug5161758 HTML injection / XSS
  begin
    l_dummy := wf_core.CheckIllegalChars(username,true);
  exception
    when OTHERS then
      fnd_document_management.error;
      return;
  end;
  l_username := upper(username);
  l_callback := wf_core.substitutespecialchars(
    wfa_html.conv_special_url_chars(callback));

  wf_directory.GetRoleInfo(l_username, realname, s0, s0, s0, s0);

  -- get the document management home node information
  fnd_document_management.get_dm_home (l_username, dm_node_id, dm_node_name);

  -- Set page title
  htp.htmlOpen;
  htp.headOpen;
  htp.title(wf_core.translate('WFDM_HOME'));
  htp.headClose;

  -- Page header
  htp.center(htf.bold(wf_core.translate('WFDM_HOME')));
  htp.p('<BR>');

  -- Column headers
  htp.tableOpen('border=1 cellpadding=3 bgcolor=white width="100%"');
  htp.tableRowOpen(cattributes=>'bgcolor=#006699');

  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
		  wf_core.translate('NAME')||'</font>',
		  calign=>'Center',
                  cattributes=>'id="t_name"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
		  wf_core.translate('DESCRIPTION')||'</font>',
		  calign=>'Center', cattributes=>'id="t_node_description"');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
		  wf_core.translate('PRODUCT')||'</font>',
		  calign=>'Center', cattributes=>'id="t_product"');

  htp.tableRowClose;
  htp.tableRowOpen;
  htp.tableRowClose;

  -- Show all nodes
  for nodes in nodes_cursor loop

    htp.tableRowOpen(null, 'TOP');

    /*
    ** Always show the currently selected node in bold
    */
    IF (dm_node_id = nodes.node_id) THEN
       -- Bug5161758 - XSS
       htp.tableData(htf.anchor2(
                       curl=>wfa_html.base_url||
                         '/fnd_document_management.set_dm_home_html?'||
                         'dm_node_id='||to_char(nodes.node_id)||
                         '&username='||l_username||
                         '&callback='|| l_callback,
                     ctext=>'<B>'||
                     wf_core.substitutespecialchars(nodes.node_name)||
                     '</B>', ctarget=>'_top'),
                    'Left', cattributes=>'headers="t_name"');

    ELSE

       htp.tableData(htf.anchor2(
                       curl=>dm_base_url||
                         '/fnd_document_management.set_dm_home_html?'||
                         'dm_node_id='||to_char(nodes.node_id)||
                         '&username='||l_username||
                         '&callback='|| l_callback,
                     ctext=>wf_core.substitutespecialchars(nodes.node_name),
                     ctarget=>'_top'),
                    'Left', cattributes=>'headers="t_name"');

    END IF;

    -- Bug5161758 - XSS
    IF (dm_node_id = nodes.node_id) THEN
       htp.tableData(htf.bold(wf_core.substitutespecialchars(nodes.node_description)), 'left',
                     cattributes=>'headers="t_node_description"');
       htp.tableData(htf.bold(wf_core.substitutespecialchars(nodes.product_name)), 'left',
                     cattributes=>'headers="t_product"');
    ELSE
       htp.tableData(wf_core.substitutespecialchars(nodes.node_description), 'left',
                     cattributes=>'headers="t_node_description"');
       htp.tableData(wf_core.substitutespecialchars(nodes.product_name), 'left', 'left',
                     cattributes=>'headers="t_product"');
    END IF;

  end loop;

  htp.tableclose;

  htp.br;

  wfa_sec.Footer;
  htp.htmlClose;

exception
  when others then
    rollback;
    wf_core.context('fnd_document_management', 'choose_home');
    fnd_document_management.Error;
end choose_home;


--
-- Product_LOV
--   Create the data for the Language List of Values
--
procedure Product_LOV (p_titles_only   IN VARCHAR2 ,
                       p_find_criteria IN VARCHAR2 )

IS

l_username   VARCHAR2(320);
l_product_id NUMBER;
l_product  VARCHAR2(80);
l_vendor  VARCHAR2(80);
l_version VARCHAR2(20);
l_row_count NUMBER := 0;

CURSOR c_product_lov (c_find_criteria IN VARCHAR2) IS
SELECT
PRODUCT_ID       ,
 PRODUCT_NAME    ,
 VENDOR_NAME     ,
 VERSION
FROM   fnd_dm_products
WHERE  product_name like c_find_criteria
ORDER  BY product_name;

BEGIN

   -- Authenticate user
   wfa_sec.GetSession(l_username);

   IF (p_titles_only = 'N') THEN

      SELECT COUNT(*)
      INTO   l_row_count
      FROM   fnd_dm_products
      WHERE  product_name like p_find_criteria||'%';

   END IF;

   htp.p(wf_core.translate('PRODUCT'));
   htp.p('4');
   htp.p(TO_CHAR(l_row_count));
   htp.p(wf_core.translate('PRODUCT'));
   htp.p('50');
   htp.p(wf_core.translate('VENDOR'));
   htp.p('35');
   htp.p(wf_core.translate('VERSION'));
   htp.p('15');
   htp.p('PRODUCT_ID');
   htp.p('0');

   IF (p_titles_only = 'N') THEN

      OPEN c_product_lov (p_find_criteria||'%');

      /*
      ** Loop through all the language rows for the given find_criteria
      ** and write them out to the web page
      */
      LOOP

         FETCH c_product_lov INTO
             l_product_id, l_product, l_vendor, l_version;

         EXIT WHEN c_product_lov%NOTFOUND;

         htp.p (l_product);
         htp.p (l_vendor);
         htp.p (l_version);
         htp.p (TO_CHAR(l_product_id));

      END LOOP;

   END IF;

exception
  when others then
    rollback;
    wf_core.context('Fnd_Document_Management', 'product_lov',p_titles_only, p_find_criteria);
    fnd_document_management.Error;
END;



/*===========================================================================

Function	get_document_token_value

Purpose		gets a token attribute from an attribute page based on
                the requested token that is passed in

============================================================================*/
PROCEDURE get_document_token_value (document_text         IN VARCHAR2,
                                    requested_token       IN VARCHAR2,
                                    token_value           OUT NOCOPY VARCHAR2)

IS

l_start_location    NUMBER :=0;
l_end_location      NUMBER :=0;

BEGIN

    /*
    ** Look for the token
    */
    l_start_location := INSTR(UPPER(document_text), requested_token);

    IF (l_start_location > 0) THEN

        /*
        ** Now set the position of the data to the first char after the token
        */
        l_start_location := l_start_location + LENGTH(requested_token);

        /*
        ** Find the end of the token value.  Add an extra < to be sure you
        ** know the last token end
        */
        l_end_location := INSTR(SUBSTR(document_text||'<',l_start_location), '<') - 1;

        token_value := SUBSTR(document_text, l_start_location, l_end_location);

    END IF;

exception
  when others then
    raise;
END get_document_token_value;

/*===========================================================================

Function	get_document_attributes

Purpose		gets the current document meta data

============================================================================*/
PROCEDURE get_document_attributes (
username               IN  Varchar2,
document_identifier    in  varchar2,
document_attributes    out nocopy fnd_document_management.fnd_document_attributes)
IS

l_start_copy            Boolean := FALSE;
l_record_num            Number := 0;
l_product_id            Number := 0;
l_dm_node_id            Number := 0;
l_document_id           Varchar2(30) := NULL;
l_version               Varchar2(10) := NULL;
l_document_name         Varchar2(240) := NULL;
l_connect_syntax        Varchar2(240) := NULL;
l_product_name          Varchar2(80) := NULL;
l_username_password     Varchar2(80) := NULL;
l_attributes_url        VARCHAR2(4000);
l_value                 VARCHAR2(240);
l_document_text         VARCHAR2(4000);
l_dummy                 boolean; -- Bug5161758 HTML injection

BEGIN
    -- Bug5161758 HTML injection
    begin
      l_dummy := wf_core.CheckIllegalChars(username,true);
    exception
      when OTHERS then
        fnd_document_management.error;
        return;
    end;
    /*
    ** Parse the document_identifier into its individual components
    ** and get all the components of the document identifer
    */
    fnd_document_management.ParseDocInfo(document_identifier,
                                         l_dm_node_id,
                                         l_document_id,
                                         l_version);

     /*
     ** Get the vendor so you know how to construct the proper URL to
     ** get the attributes
     */
     SELECT dmn.connect_syntax, dmp.product_name, dmn.product_id
     INTO   l_connect_syntax, l_product_name, l_product_id
     FROM   fnd_dm_products dmp, fnd_dm_nodes dmn
     WHERE  dmn.node_id = l_dm_node_id
     AND    dmp.product_id = dmn.product_id;

     IF (l_product_id = 10) THEN

        /*
        ** DEBUG: Livelink currently uses security to get the attributes
        ** I've asked them to drop this for their next release
        ** This statement should be removed before we ship.
        */
        l_username_password := '&username=Admin&password=manager';

         /*
         ** Create the url for fetching attributes
         */
         l_attributes_url := l_connect_syntax ||
             '/Livelink/livelink.exe?func=oracleappl.fetchattributes'||
             '&ObjectID=-2000_'||l_document_id||'_'||l_version||
             l_username_password;

     END IF;

     IF (l_product_id = 1) THEN

         l_attributes_url := l_connect_syntax ||
             '/sdkbin/app.exe/aol?template=dm_get_docname.htm&method=al=new+AOLLogin()&method=s=al.connect()&method=obj=s.getPublicObject(Long+docId)&docId='||l_document_id;

     END IF;

     /*
     ** Launch URL to fetch attributes
     */
     l_document_text := utl_http.request(l_attributes_url);

     /*
     ** Livelink uses &lt &gt for < and > respectively so replace these
     */
     IF (l_product_id = 10) THEN

          /*
          ** Delete all the header stuff to make searching faster
          */
          l_document_text := SUBSTR(l_document_text, INSTR(l_document_text,'&lt;Object ID&gt;'));

          l_document_text := REPLACE(l_document_text, '&lt;', '<');

          l_document_text := REPLACE(l_document_text, '&gt;', '>');

          --htp.p('l_document_text = '||l_document_text);

     END IF;

     document_attributes.document_identifier := document_identifier;

     /*
     ** Get the Object id to make sure its the same as what was passed in
     */
     get_document_token_value(l_document_text, '<OBJECT ID>', l_value);

     /*
     ** Get the document Name
     */
     get_document_token_value(l_document_text, '<DOCUMENTNAME>', l_value);
     document_attributes.document_name := l_value;

     /*
     ** Get the document type
     */
     get_document_token_value(l_document_text, '<DOCUMENTTYPE>', l_value);
     document_attributes.document_type := l_value;

     /*
     ** Get the filename
     */

     /*
     ** I'm commenting out a lot of the fetches of context information
     ** to ensure performance
     */
--     get_document_token_value(l_document_text, '<FILENAME>', l_value);
--     document_attributes.filename := l_value;

     /*
     ** Get the created by
     */
--     get_document_token_value(l_document_text, '<CREATEDBY>', l_value);
--     document_attributes.created_by := l_value;

     /*
     ** Get the last updated by
     */
--     get_document_token_value(l_document_text, '<LASTMODIFIED>', l_value);
--     document_attributes.last_updated_by := l_value;

     /*
     ** Get the last update date
     */
--     get_document_token_value(l_document_text, '<LASTMODIFIEDDATE>', l_value);
--     document_attributes.last_update_date := l_value;

     /*
     ** Get the locked by
     */
--     get_document_token_value(l_document_text, '<LOCKEDBY>', l_value);
--     document_attributes.locked_by := l_value;

     /*
     ** Get the locked by
     */
--     get_document_token_value(l_document_text, '<LOCKEDBY>', l_value);
--     document_attributes.locked_by := l_value;

     /*
     ** Get the size of document
     */
--     get_document_token_value(l_document_text, '<SIZE>', l_value);
--     document_attributes.document_size := l_value;

     /*
     ** Get the current document status
     */
--     get_document_token_value(l_document_text, '<STATUS>', l_value);
--     document_attributes.document_status := l_value;

     /*
     ** Get the current document version
     */
--     get_document_token_value(l_document_text, '<VERSION>', l_value);
--     document_attributes.current_version := l_value;

     /*
     ** Get the latest document version
     */
--     get_document_token_value(l_document_text, '<CURRENTVERSION>', l_value);
--     document_attributes.latest_version := l_value;
/*
     htp.p('document_identifier ='||document_attributes.document_identifier);
     htp.p('document_name       ='||document_attributes.document_name      );
     htp.p('document_type       ='||document_attributes.document_type      );
     htp.p('filename            ='||document_attributes.filename           );
     htp.p('created_by          ='||document_attributes.created_by         );
     htp.p('last_updated_by     ='||document_attributes.last_updated_by    );
     htp.p('last_update_date    ='||document_attributes.last_update_date   );
     htp.p('locked_by           ='||document_attributes.locked_by          );
     htp.p('document_size       ='||document_attributes.document_size      );
     htp.p('document_status     ='||document_attributes.document_status    );
     htp.p('current_version     ='||document_attributes.current_version    );
     htp.p('latest_version      ='||document_attributes.latest_version     );
*/
exception
  when others then
     document_attributes.document_name := wf_core.translate('WFDM_NODE_DOWN');
     document_attributes.document_type := null;
     return;
END get_document_attributes;

/*===========================================================================

Function	set_document_form_fields

Purpose		Copy the document id and name to fields on a form.  This
		function is meant to fix the browser security issue of not
		being able to call javascript from one window page to another
		when those two pages are sourced by more than one server.

============================================================================*/
PROCEDURE set_document_form_fields (document_identifier    in  varchar2) IS

start_char          NUMBER := 0;
end_char            NUMBER := 0;
document_id         VARCHAR2(240);
document_name       VARCHAR2(1000);
document_id_field   VARCHAR2(1000);
document_name_field VARCHAR2(1000);

BEGIN
   htp.headOpen;
   htp.title(wf_core.translate('WFDM_TRANSPORT_WINDOW'));
   htp.headClose;

   htp.htmlopen;

   /*
   ** Get the document id
   */
   end_char := INSTR(document_identifier, '^document_name=');
   document_id := SUBSTR(document_identifier, 1, end_char - 1);

   /*
   ** Get the document name
   */
   start_char := INSTR(document_identifier, '^document_name=') +
                  LENGTH('^document_name=');
   end_char := INSTR(document_identifier, '^document_name_field=');
   document_name := SUBSTR(document_identifier, start_char ,
                  end_char - start_char);

   /*
   ** Get the document name field name
   */
   start_char := INSTR(document_identifier, '^document_name_field=') +
                 LENGTH('^document_name_field=');
   end_char := INSTR(document_identifier, '^document_id_field=');
   document_name_field := SUBSTR(document_identifier, start_char ,
                end_char - start_char);

   /*
   ** Get the document id field name
   */
   start_char := INSTR(document_identifier, '^document_id_field=');
   document_id_field := SUBSTR(document_identifier, start_char +
                 LENGTH('^document_id_field='));

   -- Bug5161758 - XSS
   htp.p('<body bgcolor="#CCCCCC" onLoad="javascript:'||
         wf_core.substitutespecialchars(document_id_field)||'='||''''||
         wf_core.substitutespecialchars(document_id)||''''||';'||
         wf_core.substitutespecialchars(document_name_field)||'='||
         wf_core.substitutespecialchars(document_name)||';'||
         'top.opener.parent.focus();

          if (top.opener.parent.FNDDMwindow)
          {
              top.opener.parent.FNDDMwindow.close();
          }
          else
          {
             if (top.opener.FNDDMwindow)
             {
                top.opener.FNDDMwindow.close();
             }
             else
             {
                if(top.opener.parent.parent.opener)
                {
                    top.opener.parent.parent.opener.focus();
                    top.opener.parent.parent.close();
                    window.close();
                }
             }
          }
          window.close();

          return true;">');

   htp.p ('<BR>document_identifier='||wf_core.substitutespecialchars(document_identifier));
   htp.p ('<BR>document_id='||wf_core.substitutespecialchars(document_id));
   htp.p ('<BR>document_name='||wf_core.substitutespecialchars(document_name));
   htp.p ('<BR>document_id_field='||wf_core.substitutespecialchars(document_id_field));
   htp.p ('<BR>document_name_field='||wf_core.substitutespecialchars(document_name_field));

   htp.bold('<BR><BR>'||wf_core.translate('WFDM_TRANSPORT_COMPLETED'));

   htp.bodyClose;

   htp.htmlClose;

exception
  when others then
    rollback;
    wf_core.context('Fnd_Document_Management', 'set_document_form_fields');
    fnd_document_management.Error;

END set_document_form_fields;

/*===========================================================================

Function	show_transport_message

Purpose		Displays a message in the transport window when a document
                is going to be selected

============================================================================*/
PROCEDURE show_transport_message IS
BEGIN

   htp.headOpen;
   htp.title(wf_core.translate('WFDM_TRANSPORT_WINDOW'));
   htp.headClose;
   htp.bodyOpen(cattributes=>'bgcolor="#CCCCCC"');

   htp.tableOpen(cattributes=>'summary=""');
   htp.tableRowOpen;

   htp.tabledata('<IMG SRC="'||wfa_html.image_loc||'prohibit.gif" alt="' ||
                 WF_CORE.Translate('WFDM_TRANSPORT_MESSAGE') || '">',
                 cattributes=>'id=""');
   htp.tabledata(wf_core.translate('WFDM_TRANSPORT_MESSAGE'),
                 cattributes=>'id=""');

   htp.tableRowClose;
   htp.tableClose;
   htp.bodyClose;

   htp.htmlClose;

exception
  when others then
    rollback;
    wf_core.context('Fnd_Document_Management', 'show_transport_message');
    fnd_document_management.Error;

END show_transport_message;


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
p_node_id   IN VARCHAR2
) IS
BEGIN
 null;
exception
  when others then
    rollback;
    wf_core.context('Fnd_Document_Management', 'Dm_Nodes_Confirm_Delete', p_node_id);
    fnd_document_management.Error;

END Dm_Nodes_Confirm_Delete;


/*===========================================================================

Function	Dm_Nodes_Delete

Purpose		Does the physical delete of a document node after the
		delete window has been confirmed by the user
============================================================================*/
procedure Dm_Nodes_Delete (
p_node_id   IN VARCHAR2
) IS
BEGIN
  null;
exception
  when others then
    rollback;
    wf_core.context('Fnd_Document_Management', 'Dm_Nodes_Delete', p_node_id);
    fnd_document_management.Error;

END Dm_Nodes_Delete;

/*===========================================================================

Function	get_ticket

Purpose		Get the current value of the ticket.  If the ticket
                is not set then create a random number and insert it

============================================================================*/
FUNCTION get_ticket (username     IN VARCHAR2) RETURN VARCHAR2
IS

l_ticket  VARCHAR2(240);

BEGIN

  /*
  ** Get the current value of the ticket
  */
  begin

     l_ticket := fnd_preference.get (username, 'WF', 'TICKET');

  exception
     when others then
        l_ticket := NULL;
  end;

  /*
  ** if you don't have a ticket value then go get one and insert it into
  ** the pref table
  */
  if (NVL(l_ticket, '-1') = '-1') then

     l_ticket := Wf_Core.Random;

     fnd_preference.put (username, 'WF', 'TICKET', l_ticket);

  end if;

  return (l_ticket);

exception
    when others then
       wf_core.context('fnd_document_management',
                       'get_ticket',
                       username);
       raise;

end get_ticket;



/*===========================================================================

Function	validate_ticket

Purpose		Function for the DM system to validate the current value
		of the ticket for single signon.  The DM vendor will
		create a value of the ticket and pass it to us.  They will
                keep track of the value in that ticket so when they call us
		to validate the ticket, they will know what it is.  This version
                of the function is called directly though sql*net.

============================================================================*/
PROCEDURE validate_ticket (username    IN VARCHAR2,
                          ticket       IN VARCHAR2,
                          valid_ticket OUT NOCOPY NUMBER) IS

l_ticket  VARCHAR2(240);
l_valid_ticket NUMBER := 0;

BEGIN

  /*
  ** Set the user default value
  */
  l_ticket := fnd_preference.get (username, 'WF', 'TICKET');

  if (l_ticket = ticket) then

      l_valid_ticket := 1;

  else

      l_valid_ticket := 0;

  end if;

  valid_ticket := l_valid_ticket;

exception
    when others then
       wf_core.context('fnd_document_management',
                       'validate_ticket',
                       username,
                       ticket);
       raise;

end validate_ticket;


/*===========================================================================

Function	validate_ticket_http

Purpose		Function for the DM system to validate the current value
		of the ticket for single signon.  The DM vendor will
		create a value of the ticket and pass it to us.  They will
                keep track of the value in that ticket so when they call us
		to validate the ticket, they will know what it is.  This
                version of the procedure is called from a http request

============================================================================*/
PROCEDURE validate_ticket_HTTP (username    IN VARCHAR2,
                                ticket       IN VARCHAR2) IS

l_ticket  VARCHAR2(240);

BEGIN

  /*
  ** Set the user default value
  */
  l_ticket := fnd_preference.get (username, 'WF', 'TICKET');

  if (l_ticket = ticket) then

      htp.p('<VALIDTICKET>1</VALIDTICKET>');

  else

      htp.p('<VALIDTICKET>0</VALIDTICKET>');

  end if;

exception
    when others then
       wf_core.context('fnd_document_management',
                       'validate_ticket_http',
                       username,
                       ticket);
       raise;

end validate_ticket_http;


/*===========================================================================

Function	modulate_ticket

Purpose		Function for the DM system to update the current value
		of the ticket for single signon.  The DM vendor will
		create a value of the ticket and pass it to us.  They will
                keep track of the value in that ticket so when we call them
		with the value they will know what that value is.

                If the ticket value is null then we will create a random
		number and plug it in.

============================================================================*/
PROCEDURE modulate_ticket (username    IN VARCHAR2,
                           ticket      IN VARCHAR2)
IS

BEGIN

  /*
  ** Set the ticket for this user
  */
  fnd_preference.put (username, 'WF', 'TICKET', ticket);

exception
    when others then
       wf_core.context('fnd_document_management',
                       'modulate_ticket',
                       username,
                       ticket);
       raise;

END modulate_ticket;

PROCEDURE test (stringy    IN VARCHAR2) IS
BEGIN
   -- Bug5161758 - XSS
   htp.p (wf_core.substitutespecialchars(stringy));
end;


PROCEDURE show_test_message (
document_id  IN VARCHAR2,
display_type IN VARCHAR2,
document     IN OUT NOCOPY VARCHAR2,
document_type IN OUT NOCOPY VARCHAR2) IS

BEGIN


   document := '<DIR>
  <DIR>
<hr SIZE=3><b><font color="#000099"></font></b>
<p><b><font color="#000099">Terminology</font></b>
  <p>Applications National Language Support&nbsp; (NLS) is the ability to
run Oracle Applications in one (1) national language (either American English,
or one of the available translations).&nbsp; In contrast Applications MLS
(Multi Language Support) is the ability to run Oracle Applications in more
than a single language on a single database instance.
<br>&nbsp;
  <br><b><font color="#000099">Release 10.7</font></b>
<br>&nbsp;
<br>The standard Release 10.7 product provides NLS support.&nbsp; Supported
functionality consists of installing and running Release 10.7 in exactly
one (1) of 25 national languages.
<br>&nbsp;
<br>The installation process for a translation installs both the US English
forms and reports and the forms and reports for the translation (or
    "base
    language").&nbsp; The installation first populates the seeded reference
data of the applications with English, then overlays that seed data with
the translated seed data for the base language.&nbsp; The result is that
only one language of seed data is present in the reference data tables.&nbsp;
Patches applied to the system assume that only the base language is being
maintained.
<br>&nbsp;
<br>Many architectural underpinnings of multilingual support are present
in 10.7, so it is possible for Consulting to make modifications that enable
some multilingual operation within carefully defined limits.&nbsp; We have
satisfied customers today running on the Consulting multilingual solution.&nbsp;
While Consulting and Development have worked cooperatively to ensure that
the consulting solution is consistent with product direction, it should
be clearly understood that maintenance of this environment requires Consulting
involvement.
<br>&nbsp;
<br><b><font color="#000099">Release 11.0</font></b>
  <br>&nbsp;
<br>Release 11 introduces limited multilingual support.&nbsp; Release 11
supports installation of forms, reports, messages, help, and *some* reference
data in multiple national languages in a single instance.
<br>&nbsp;
<br>There are some important limitations to understand, such as the requirement
for all users to operate with a common radix character, which are documented
in the Oracle Applications NLS Installation Manual.
<br>&nbsp;
<br>The languages installed must share a common database character set
other than Unicode (UTF-8).&nbsp; For example, all Western European languages
can be supported with the WE8ISO8859P1 date character set, but this character
set does not support Greek or Russian.&nbsp; Asian character sets support
ASCII as a subset, so it is possible to choose the Japanese, Chinese, or
Korean standard character set and run both that language and English in
a single instance.&nbsp; But it is not possible to run, say, both Japanese
and Korean in a single character set.
<br>&nbsp;
<br>Data modeled multilingually in Release 11.0 is limited to the AOL tables.&nbsp;
Textual items such as menus, report names, and segment value descriptions
for the Accounting Flexfield can be installed and maintained in multiple
languages.&nbsp; Consulting can provide multilingual support for additional
reference data elements, either to support online presentation in the language
of the users choice or to support printing of certain external documents
in the trading partners language of choice.
<br>&nbsp;

<br><b><font color="#000099">Release 11.5 and beyond</font></b>
<br>&nbsp;
<br>The highest multilingual priorities for Release 11.5 are:
<p>&nbsp;- support for the Unicode (UTF-8) database character set
<br>&nbsp;- support for the reference data elements needed to produce customer-facing
external documents in the language of the customers choice
<br>&nbsp;
<br>Beyond Release 11.5 we plan to continue to add multilingual support
to remaining reference data elements in the system based on customer feedback.
<br>&nbsp;
<br>Our feedback to date has been that it is not a requirement to support
multilingual system administration or implementation screens (so that
you could, for example, view the names of concurrent manager workshifts
in multiple languages.)
<br>&nbsp;
    </DIR>';

end;

END fnd_document_management;

/
