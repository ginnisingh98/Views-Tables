--------------------------------------------------------
--  DDL for Package Body HR_OWNER_DEFINITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_OWNER_DEFINITIONS_PKG" AS
/* $Header: pyowd01t.pkb 115.1 99/07/17 06:19:21 porting ship  $ */
--
  procedure check_unique ( p_rowid            in varchar2,
			   p_session_id       in number,
			   p_application_name in varchar2) is
  cursor c1 is
      select '1'
      from   hr_owner_definitions hod,
	     fnd_application_vl   app
      where  hod.product_short_name      = app.application_short_name
      and    upper(app.application_name) = upper(p_application_name)
      and    hod.session_id              = p_session_id
      and    ( p_rowid is null or
		( p_rowid is not null and p_rowid <> hod.rowid ) ) ;
  l_dummy varchar2(1) ;
  begin
     open c1 ;
     fetch c1 into l_dummy ;
     if c1%found
     then close c1 ;
	  hr_utility.set_message(801,'HR_6661_OWNER_ALREADY_EXISTS');
	  hr_utility.raise_error ;
     end if ;
     close c1 ;
  end check_unique ;
--

--
  procedure insert_row(p_rowid                in out varchar2,
		       p_session_id	      in number ,
		       p_product_short_name   in varchar2 ) is
  --
  cursor c1 is
      select rowid
      from   hr_owner_definitions
      where  session_id         = p_session_id
      and    product_short_name = p_product_short_name ;
  --
  begin
--
    insert into HR_OWNER_DEFINITIONS
	   ( SESSION_ID,
	     PRODUCT_SHORT_NAME )
    values ( p_session_id,
             p_product_short_name) ;
--
     open c1 ;
     fetch c1 into p_rowid ;
     close c1 ;
--
  end insert_row ;
--
  procedure delete_row(p_rowid   in varchar2) is
  --
  begin
  --
    delete from HR_OWNER_DEFINITIONS
    where  ROWID = p_rowid;
  --
  end delete_row;
--
END HR_OWNER_DEFINITIONS_PKG;

/
