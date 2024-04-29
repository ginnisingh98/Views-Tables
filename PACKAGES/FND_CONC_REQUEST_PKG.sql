--------------------------------------------------------
--  DDL for Package FND_CONC_REQUEST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CONC_REQUEST_PKG" AUTHID CURRENT_USER as
/* $Header: AFCPFCRS.pls 120.2.12010000.2 2011/05/09 19:06:40 pferguso ship $ */



  procedure get_program_info	(cpid	in number,
				 appid	in number,
				 pname	out nocopy varchar2,
				 sname	out nocopy varchar2,
				 srs	in out nocopy varchar2,
				 eflag	in out nocopy varchar2,
				 rflag	in out nocopy varchar2,
				 qcode	in out nocopy varchar2,
				 eopts	in out nocopy varchar2,
				 prntr	in out nocopy varchar2,
				 pstyl	in out nocopy varchar2,
				 rstyl	in out nocopy varchar2);
  pragma restrict_references    (get_program_info, WNDS);

  function get_user_name	(uid	in number)
		    		 return varchar2;
  pragma restrict_references    (get_user_name, WNDS, WNPS);

  procedure get_phase_status	(pcode	in char,
				 scode	in char,
				 hold	in char,
				 enbld	in char,
				 cancel	in char,
				 stdate	in date,
				 rid	in number,
		    		 phase	out nocopy varchar2,
				 status out nocopy varchar2);
  pragma restrict_references    (get_phase_status, WNDS);

  procedure get_phase_status (pcode  in char,
			    scode  in char,
			    hold   in char,
			    enbld  in char,
			    cancel in char,
			    stdate in date,
			    rid    in number,
			    phase  out nocopy varchar2,
			    status out nocopy varchar2,
			    upcode out nocopy varchar2,
			    uscode out nocopy varchar2);
  pragma restrict_references    (get_phase_status, WNDS);

  function get_user_phase_code	(phase	in varchar2)
				 return	varchar2;
  pragma restrict_references    (get_user_phase_code, WNDS);

  function get_user_status_code	(status	in varchar2)
				 return	varchar2;
  pragma restrict_references    (get_user_status_code, WNDS);

  function get_user_print_style	(pstyl	in varchar2)
		    		 return varchar2;
  pragma restrict_references    (get_user_print_style, WNDS);

  function lock_parent		(rid	in number)
				 return boolean;

  function restart_parent	(rid	in number,
				 prid	in number,
				 uid	in number)
				 return boolean;

  procedure delete_children	(rid	in number,
				 uid	in number);

  function request_position	(rid	in number,
				 pri	in number,
				 stdate	in date,
				 qname	in varchar2,
				 qappid	in number)
		    		 return number;
  pragma restrict_references    (request_position, WNDS);

  function running_requests	(qname	in varchar2,
				 qappid	in number)
				 return number;
  pragma restrict_references    (running_requests, WNDS);

  function pending_requests	(qname	in varchar2,
				 qappid	in number)
				 return number;
  pragma restrict_references    (pending_requests, WNDS);


  function encode_attribute_order (srs_flag         in varchar2,
                                   requested_by     in number,
                                   req_resp_id      in number,
                                   req_resp_appl_id in number,
                                   prog_appl_id     in number,
                                   prog_name        in varchar2)
                                   return varchar2;
  pragma restrict_references (encode_attribute_order, WNDS, WNPS);

  procedure fndcpqcr_init(sys_mode boolean, resp_access boolean);
  pragma restrict_references    (running_requests, WNDS);

  function role_info( in_name in varchar2,
                    in_system in varchar2,
                    in_system_id in number)
        return varchar2;
  pragma restrict_references (role_info, WNDS);

end FND_CONC_REQUEST_PKG;

/
