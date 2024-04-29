--------------------------------------------------------
--  DDL for Package HR_ASSIGNMENT_SET_AMDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSIGNMENT_SET_AMDS_PKG" AUTHID CURRENT_USER as
/* $Header: pyasm01t.pkh 115.0 99/07/17 05:43:17 porting ship $ */
--
  procedure insert_row(p_rowid             in out varchar2,
                       p_assignment_id         in number,
                       p_assignment_set_id     in number,
                       p_include_or_exclude    in varchar2);
  --
  procedure update_row(p_rowid                 in varchar2,
                       p_assignment_id         in number,
                       p_assignment_set_id     in number,
                       p_include_or_exclude    in varchar2);
  --
  procedure delete_row(p_rowid   in varchar2);
  --
  procedure lock_row(p_rowid                   in varchar2,
                       p_assignment_id         in number,
                       p_assignment_set_id     in number,
                       p_include_or_exclude    in varchar2);

  --
end HR_ASSIGNMENT_SET_AMDS_PKG;

 

/
