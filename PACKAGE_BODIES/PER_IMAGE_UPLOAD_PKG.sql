--------------------------------------------------------
--  DDL for Package Body PER_IMAGE_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_IMAGE_UPLOAD_PKG" as
/* $Header: peimgupl.pkb 120.2 2005/08/08 04:51:33 mroberts noship $ */


g_image_is_blob boolean := null;

function image_is_blob return boolean  is
l_data_type varchar2(100);
l_username  varchar2(100);
begin

  if g_image_is_blob is null
  then


    -- There may be fnd/ad utility routines for one or
    -- both of these cursors. To check - and ideally
    -- replace.

    select u.oracle_username
    into   l_username
    from   fnd_oracle_userid         u,
	   fnd_product_installations p
    where  p.application_id = 800
    and    u.oracle_id      = p.oracle_id;

    select c.data_type
    into   l_data_type
    from   all_tab_columns           c
    where  c.owner          = l_username
    and    c.table_name     = 'PER_IMAGES'
    and    c.column_name    = 'IMAGE' ;

    g_image_is_blob := ( l_data_type = 'BLOB' );

   end if;

   return (g_image_is_blob);

end image_is_blob;

-- procedure generic_error - copied from code in:
-- $FND_TOP/patch/115/sql/AFCINFOB.pls
--

procedure generic_error(routine in varchar2,
                        errcode in number,
                        errmsg in varchar2) is
l_msg varchar2(2000);
begin
    fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
    fnd_message.set_token('ROUTINE', routine);
    fnd_message.set_token('ERRNO', errcode);
    fnd_message.set_token('REASON', errmsg);
    fnd_message.raise_error;
end;

--
-- Transfer_pvt
--
-- java wrapper for java upload code
--

function Transfer_pvt (file_id       in number,
                       image_id      in number,
                       connectString in varchar2,
                       un            in varchar2,
                       pw            in varchar2,
                       msg           in out nocopy varchar2) return number
   as language java
   name 'oracle.apps.per.util.ImageUtils.lob_to_img(long,
                                                    long,
                                                    java.lang.String,
                                                    java.lang.String,
                                                    java.lang.String,
                                                    java.lang.String[])
   return int' ;

--
-- Transfer
-- Only the file_id,image_id parameters are relevant if the
-- PER_IMAGES.IMAGE is a BLOB rather than a LONG RAW
function Transfer (file_id       in number,
                   image_id      in number,
                   connectString in varchar2,
                   un            in varchar2,
                   pw            in varchar2,
                   msg           in out nocopy varchar2) return int is

l_retval number;
--
begin
--

  if  ( image_is_blob )
  then

    execute immediate
        'UPDATE PER_IMAGES
         SET IMAGE = (SELECT FILE_DATA
                      FROM   FND_LOBS
     	              WHERE  FILE_ID = :1)
         WHERE IMAGE_ID = :2 '
    using file_id , image_id ;

     if ( sql%rowcount = 1 ) then
        l_retval := 1 ;
     else
        l_retval := 0 ;
     end if;

  else

    -- call java code
    l_retval := Transfer_pvt (file_id,
                              image_id,
                              connectString,
                              un,
                              pw,
                              msg);
  end if;

  return (l_retval);

  exception
    when others then
    --
    -- DK
    -- The message text for a javavm error contains the main
    -- details - there is usually a generic error code like
    -- ORA-29532, ORA-29540. We raise -20001 to ensure that
    -- the message text is displayed in forms. For some reason
    -- that message text would not otherwise be displayed.
    -- This is probably a bug in AOL's message handler
    --
    -- sqlcode is not being passed to avoid the error number appearing
    -- twice
    --
    generic_error(routine => 'PER_IMAGE_UPLOAD_PKG',
                  errcode =>  null,
                  errmsg  =>  sqlerrm);


--
end Transfer;
--

--
-- LOAD
--
procedure Load( doc       in varchar2,
                access_id in number ) is

file_id number ;

begin

file_id :=  fnd_gfm.confirm_upload(
              access_id    => access_id,
              file_name    => doc,
	      program_name => 'PERWSIMG');

htp.htmlopen;
htp.p('Loaded: '||doc||' File ID: '||file_id);
htp.htmlclose;

exception
  when others then
    htp.htmlopen;
    htp.p('error in load');
    htp.htmlclose;
    raise;
end Load;

--
-- LAUNCH
--
procedure Launch is

form_action varchar2(2000);
access_id   number := fnd_gfm.authorize(NULL);
user_id     number := fnd_profile.value('USER_ID');

begin

form_action := fnd_gfm.construct_upload_url(fnd_web_config.gfm_agent,
                                           'per_image_upload_pkg.Load',
                                            access_id);

htp.htmlOpen;

htp.p('<form action='||form_action||
        ' method=post enctype="multipart/form-data">');


htp.p('<input type="File" name="doc"></input>');

htp.p('<input type="Hidden" name="access_id" value='||access_id||'>'||
      '</input>');

htp.p('<input type="Hidden" name="user_id" value='||user_id||'>'||
      '</input>');

htp.p('<input type="Submit" value="Submit"></input>');

htp.p('</form>');

htp.htmlClose;

end Launch;

end PER_IMAGE_UPLOAD_PKG;

/
