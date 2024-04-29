--------------------------------------------------------
--  DDL for Package FND_CP_TMSRV_PIPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CP_TMSRV_PIPE" AUTHID CURRENT_USER as
/* $Header: AFCPTMPS.pls 120.0 2005/09/02 18:52:12 pferguso noship $ */


procedure initialize (e_code in out nocopy number,
                      qid    in     number,
                      pid    in     number);


procedure read_message (e_code  in out nocopy number,
		                timeout in     number,
		                pktyp   in out nocopy varchar2,
		                enddate in out nocopy varchar2,
		                reqid   in out nocopy number,
		                return_id in out nocopy varchar2,
		                nlslang in out nocopy varchar2,
 		                nls_num_chars in out nocopy varchar2,
  	  	                nls_date_lang in out nocopy varchar2,
		                secgrpid in out nocopy number,
		                usrid   in out nocopy number,
		                rspapid in out nocopy number,
		                rspid   in out nocopy number,
		                logid   in out nocopy number,
		                apsname in out nocopy varchar2,
		                program in out nocopy varchar2,
                        numargs in out nocopy number,
                        org_type in out nocopy varchar2,
                        org_id  in out nocopy number,
		                arg_1   in out nocopy varchar2,
		                arg_2   in out nocopy varchar2,
		                arg_3   in out nocopy varchar2,
		                arg_4   in out nocopy varchar2,
		                arg_5   in out nocopy varchar2,
		                arg_6   in out nocopy varchar2,
		                arg_7   in out nocopy varchar2,
		                arg_8   in out nocopy varchar2,
		                arg_9   in out nocopy varchar2,
		                arg_10  in out nocopy varchar2,
		                arg_11  in out nocopy varchar2,
		                arg_12  in out nocopy varchar2,
		                arg_13  in out nocopy varchar2,
		                arg_14  in out nocopy varchar2,
		                arg_15  in out nocopy varchar2,
		                arg_16  in out nocopy varchar2,
		                arg_17  in out nocopy varchar2,
		                arg_18  in out nocopy varchar2,
		                arg_19  in out nocopy varchar2,
                        arg_20  in out nocopy varchar2);


procedure write_message (e_code  in out nocopy number,
			             return_id  in     varchar2,
			             pktyp   in     varchar2,
			             reqid	in     number,
			             outcome in     varchar2,
                         message in     varchar2);


end fnd_cp_tmsrv_pipe;

 

/
