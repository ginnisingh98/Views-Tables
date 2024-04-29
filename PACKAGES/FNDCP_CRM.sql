--------------------------------------------------------
--  DDL for Package FNDCP_CRM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FNDCP_CRM" AUTHID CURRENT_USER as
/* $Header: AFCPCRMS.pls 120.1.12010000.2 2016/09/19 20:48:47 pferguso ship $ */



--
-- Returns the number of mgr procs that can run the request
--

function mgr_up (reqid in number) return number;
pragma restrict_references (mgr_up, WNDS);


-- The following function is used by FND_REQUEST package in AFCPREQ*.pls
-- and src/process/fdprrc.lpc.  This used to be in AFCPREQ*.pls, but due
-- to the infamous 64K limit, had to move out to here.

  --
  -- Get conflicts domain id.
  --
  -- Extract the value in parameter named by cd_param.
  -- This value is a Conflicts Domain Name.
  -- If the domain by this name exists, return its cd_id.
  -- Else, insert a new domain by the name and return the new cd_id.
  --
  -- The routine is used at request submission time by programs that
  -- have the Conflicts Domain name defined in a parameter.
  --
  function get_cd_id (app      in varchar2,
		      program  in varchar2,
		      user_id  in number,
		      login_id in number,
		      cd_param in varchar2,
		      nargs    in number,
		      a1       in varchar2 default chr(0),
		      a2       in varchar2 default chr(0),
		      a3       in varchar2 default chr(0),
		      a4       in varchar2 default chr(0),
		      a5       in varchar2 default chr(0),
		      a6       in varchar2 default chr(0),
		      a7       in varchar2 default chr(0),
		      a8       in varchar2 default chr(0),
		      a9       in varchar2 default chr(0),
		      a10      in varchar2 default chr(0),
		      a11      in varchar2 default chr(0),
		      a12      in varchar2 default chr(0),
		      a13      in varchar2 default chr(0),
		      a14      in varchar2 default chr(0),
		      a15      in varchar2 default chr(0),
		      a16      in varchar2 default chr(0),
		      a17      in varchar2 default chr(0),
		      a18      in varchar2 default chr(0),
		      a19      in varchar2 default chr(0),
		      a20      in varchar2 default chr(0),
		      a21      in varchar2 default chr(0),
		      a22      in varchar2 default chr(0),
		      a23      in varchar2 default chr(0),
		      a24      in varchar2 default chr(0),
		      a25      in varchar2 default chr(0),
		      a26      in varchar2 default chr(0),
		      a27      in varchar2 default chr(0),
		      a28      in varchar2 default chr(0),
		      a29      in varchar2 default chr(0),
		      a30      in varchar2 default chr(0),
		      a31      in varchar2 default chr(0),
		      a32      in varchar2 default chr(0),
		      a33      in varchar2 default chr(0),
		      a34      in varchar2 default chr(0),
		      a35      in varchar2 default chr(0),
		      a36      in varchar2 default chr(0),
		      a37      in varchar2 default chr(0),
		      a38      in varchar2 default chr(0),
		      a39      in varchar2 default chr(0),
		      a40      in varchar2 default chr(0),
		      a41      in varchar2 default chr(0),
		      a42      in varchar2 default chr(0),
		      a43      in varchar2 default chr(0),
		      a44      in varchar2 default chr(0),
		      a45      in varchar2 default chr(0),
		      a46      in varchar2 default chr(0),
		      a47      in varchar2 default chr(0),
		      a48      in varchar2 default chr(0),
		      a49      in varchar2 default chr(0),
		      a50      in varchar2 default chr(0),
		      a51      in varchar2 default chr(0),
		      a52      in varchar2 default chr(0),
		      a53      in varchar2 default chr(0),
		      a54      in varchar2 default chr(0),
		      a55      in varchar2 default chr(0),
		      a56      in varchar2 default chr(0),
		      a57      in varchar2 default chr(0),
		      a58      in varchar2 default chr(0),
		      a59      in varchar2 default chr(0),
		      a60      in varchar2 default chr(0),
		      a61      in varchar2 default chr(0),
		      a62      in varchar2 default chr(0),
		      a63      in varchar2 default chr(0),
		      a64      in varchar2 default chr(0),
		      a65      in varchar2 default chr(0),
		      a66      in varchar2 default chr(0),
		      a67      in varchar2 default chr(0),
		      a68      in varchar2 default chr(0),
		      a69      in varchar2 default chr(0),
		      a70      in varchar2 default chr(0),
		      a71      in varchar2 default chr(0),
		      a72      in varchar2 default chr(0),
		      a73      in varchar2 default chr(0),
		      a74      in varchar2 default chr(0),
		      a75      in varchar2 default chr(0),
		      a76      in varchar2 default chr(0),
		      a77      in varchar2 default chr(0),
		      a78      in varchar2 default chr(0),
		      a79      in varchar2 default chr(0),
		      a80      in varchar2 default chr(0),
		      a81      in varchar2 default chr(0),
		      a82      in varchar2 default chr(0),
		      a83      in varchar2 default chr(0),
		      a84      in varchar2 default chr(0),
		      a85      in varchar2 default chr(0),
		      a86      in varchar2 default chr(0),
		      a87      in varchar2 default chr(0),
		      a88      in varchar2 default chr(0),
		      a89      in varchar2 default chr(0),
		      a90      in varchar2 default chr(0),
		      a91      in varchar2 default chr(0),
		      a92      in varchar2 default chr(0),
		      a93      in varchar2 default chr(0),
		      a94      in varchar2 default chr(0),
		      a95      in varchar2 default chr(0),
		      a96      in varchar2 default chr(0),
		      a97      in varchar2 default chr(0),
		      a98      in varchar2 default chr(0),
		      a99      in varchar2 default chr(0),
		      a100     in varchar2 default chr(0))
		      return number;

--
-- Remove all unused 'dynamic' conflict domains
-- in order to manage the size of the table.
--
procedure purge_dynamic_domains;


function is_req_running (reqid in number) return varchar2;


end FNDCP_CRM;

/
