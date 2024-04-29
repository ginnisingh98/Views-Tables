--------------------------------------------------------
--  DDL for Package HXC_ARCHIVE_RESTORE_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ARCHIVE_RESTORE_PROCESS" AUTHID CURRENT_USER as
/* $Header: hxcarcrespkg.pkh 120.2.12010000.2 2008/10/08 11:57:56 asrajago ship $ */

-------------------------------------------------------------------
-- for description about all the following functions and procedures
-- please refer the package body
-------------------------------------------------------------------

--
-- EXCEPTION
--

e_chunk_count exception;

PROCEDURE define_data_set(errbuf 		OUT NOCOPY VARCHAR2,
			  retcode 		OUT NOCOPY NUMBER,
			  p_data_set_name 	IN VARCHAR2,
			  p_description 	IN VARCHAR2,
		   	  p_start_date 		IN VARCHAR2,
			  p_stop_date 		IN VARCHAR2);


procedure undo_define_data_set
(
errbuf OUT NOCOPY varchar2,
retcode OUT NOCOPY number,
p_data_set_id in number
);

procedure validate_data_set
(
errbuf OUT NOCOPY varchar2,
retcode OUT NOCOPY number,
p_data_set_id in number
);

procedure archive_data_set
(
errbuf OUT NOCOPY varchar2,
retcode OUT NOCOPY number,
p_data_set_id in number,
p_ignore_errors in varchar2
);

procedure restore_data_set
(
errbuf OUT NOCOPY varchar2,
retcode OUT NOCOPY number,
p_data_set_id in number
);

FUNCTION check_null_data_set_id
RETURN BOOLEAN;

FUNCTION check_data_mismatch
RETURN BOOLEAN;

End hxc_archive_restore_process;

/
