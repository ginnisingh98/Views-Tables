--------------------------------------------------------
--  DDL for Package WIP_TRANSACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_TRANSACTIONS_PKG" AUTHID CURRENT_USER as
/* $Header: wiptxnss.pls 115.8 2002/11/29 14:44:12 rmahidha ship $ */

/*=====================================================================+
 | PROCEDURE
 |   MOV_CLEANUP
 |
 | PURPOSE
 |   Cleanup move transactions from the database after a online server
 |   side processor fails using Remote Procedure calls;  reposts records
 |
 | ARGUMENTS
 |   IN
 |     mov_group_id         Move transaction group id
 |     res_group_id         Resource transaction group id
 |     mtl_header_id        Material transaction header id
 |     bf_page              If 2, then issues savepoint and posts bf records
 |     save_point           save point name to issue
 |   OUT
 |     err_code             0 on success, -1 on error
 |     err_app              Mesg dictionary application
 |     err_msg              Mesg dictionary message to display on error
 |
 | EXCEPTIONS
 |
 | NOTES
 |
 +=====================================================================*/
  procedure mov_cleanup(
    mov_group_id  in number,
    res_group_id  in number,
    mtl_header_id in number,
    bf_page       in number,
    save_point    in varchar2,
    err_code      out NOCOPY number,
    err_app       out NOCOPY varchar2,
    err_msg       out NOCOPY varchar2);

/*=====================================================================+
 | PROCEDURE
 |   CMP_CLEANUP
 |
 | PURPOSE
 |   Cleanup completion transactions from the database after a online server
 |   side processor fails using Remote Procedure calls;  reposts records
 |
 | ARGUMENTS
 |   IN
 |     mtl_header_id        Material transaction header id
 |     action_id            Action ID: return or completion
 |     criteria_sp          Save point for criteria entry
 |     entry_sp             Save point for completion entry
 |     insert_sp            Save point for completion inserts
 |     bf_page              If 2, then issues savepoint and posts bf records
 |   OUT
 |     err_code             0 on success, -1 on error
 |     err_app              Mesg dictionary application
 |     err_msg              Mesg dictionary message to display on error
 |
 | EXCEPTIONS
 |
 | NOTES
 |
 +=====================================================================*/
  procedure cmp_cleanup(
    mtl_header_id in number,
    action_id     in number,
    criteria_sp   in varchar2,
    entry_sp      in varchar2,
    insert_sp     in varchar2,
    bf_page       in number,
    err_code      out NOCOPY number,
    err_app       out NOCOPY varchar2,
    err_msg       out NOCOPY varchar2);

/*=====================================================================+
 | PROCEDURE
 |   MTL_CLEANUP
 |
 | PURPOSE
 |   Cleanup WIP material transactions from the database after a online server
 |   side processor fails using Remote Procedure calls;  reposts records
 |
 | ARGUMENTS
 |   IN
 |     mtl_header_id        Material transaction header id
 |     entry_sp             Save point for material entry
 |   OUT
 |     err_code             0 on success, -1 on error
 |     err_app              Mesg dictionary application
 |     err_msg              Mesg dictionary message to display on error
 |
 | EXCEPTIONS
 |
 | NOTES
 |
 +=====================================================================*/
  procedure mtl_cleanup(
    mtl_header_id in number,
    entry_sp      in varchar2,
    err_code      out NOCOPY number,
    err_app       out NOCOPY varchar2,
    err_msg       out NOCOPY varchar2);

/*=====================================================================+
 | PROCEDURE
 |   CLEANUP
 |
 | PURPOSE
 |   Cleanup move, resource, and wip material transactions from the
 |   database after a online server side processor fails using
 |   Remote Procedure calls
 |
 | ARGUMENTS
 |   IN
 |     mov_group_id         Move transaction group id
 |     res_group_id         Resource transaction group id
 |     mtl_header_id        Material transaction header id
 |
 | EXCEPTIONS
 |  Calls FND_MESSAGE.RAISE_ERROR upon detection of error.
 |
 | NOTES
 |
 +=====================================================================*/
  procedure cleanup(
    mov_group_id        in number,
    res_group_id        in number,
    mtl_header_id       in number);


  function rec_count_MMTT (mtl_hdr_id   in NUMBER) return NUMBER;
  procedure cln_up_MMTT (txn_hdr_id   in NUMBER);
  procedure cln_up_MTI (txn_hdr_id   in NUMBER);

  PRAGMA RESTRICT_REFERENCES(rec_count_MMTT, WNDS, WNPS);

end WIP_TRANSACTIONS_PKG;

 

/
