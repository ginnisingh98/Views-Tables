--------------------------------------------------------
--  DDL for Package HR_OWNER_DEFINITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_OWNER_DEFINITIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: pyowd01t.pkh 115.0 99/07/17 06:19:24 porting ship $ */
--
-- Checks that the given product is unique for the session.
  procedure check_unique ( p_rowid            in varchar2,
			   p_session_id       in number,
			   p_application_name in varchar2 ) ;
--
  procedure insert_row(p_rowid                in out varchar2,
		       p_session_id	      in number ,
		       p_product_short_name   in varchar2 ) ;

--
  procedure delete_row(p_rowid   in varchar2) ;
--
-- Note that lock_row is not necessary as the the session id is part of
-- the key for the table
--
END HR_OWNER_DEFINITIONS_PKG;

 

/
