--------------------------------------------------------
--  DDL for Package BEN_DM_INPUT_FILE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DM_INPUT_FILE_PKG" AUTHID CURRENT_USER as
/* $Header: benfdmdmfile.pkh 120.0 2006/05/04 04:48:17 nkkrishn noship $ */
--
procedure read_file
(p_migration_data ben_dm_utility.r_migration_rec,
 p_delimiter      in varchar2 default ';'
);

end ben_dm_input_file_pkg;

 

/
