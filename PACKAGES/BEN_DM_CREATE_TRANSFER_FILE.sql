--------------------------------------------------------
--  DDL for Package BEN_DM_CREATE_TRANSFER_FILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DM_CREATE_TRANSFER_FILE" AUTHID CURRENT_USER AS
/* $Header: benfdmcrfl.pkh 120.0 2006/06/13 14:54:41 nkkrishn noship $ */

procedure main
(
 p_dir_name             in   varchar2,
 p_file_name            in   varchar2,
 p_delimiter            in   varchar2
) ;

end ben_dm_create_transfer_file;

 

/
