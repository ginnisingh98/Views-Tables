--------------------------------------------------------
--  DDL for Package OE_PURGE_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PURGE_WF" AUTHID CURRENT_USER AS
  /* $Header: OEXVPWFS.pls 120.0.12010000.1 2009/06/24 07:57:59 spothula noship $ */
TYPE wf_details_type
IS
  RECORD
  (
    instance_label VARCHAR2(30) ,
    item_key       VARCHAR2(240) ,
    order_number   NUMBER ,
    org_id         NUMBER ) ;
TYPE wf_details_tbl_type
IS
  TABLE OF wf_details_type INDEX BY binary_integer;
TYPE wf_type
IS
  RECORD
  (
    item_type VARCHAR2(8) ,
    item_key  VARCHAR2(240) );
TYPE wf_tbl_type
IS
  TABLE OF wf_type INDEX BY BINARY_INTEGER;
PROCEDURE purge_orphan_errors
  (
    p_item_key IN VARCHAR2 DEFAULT NULL );
PROCEDURE attempt_to_close
  (
    p_item_key IN VARCHAR2 DEFAULT NULL );
PROCEDURE purge_item_type
  (
    p_item_type IN VARCHAR2 );
PROCEDURE purge_om_flows
  (
    errbuf OUT NOCOPY  VARCHAR2 ,
    retcode OUT NOCOPY VARCHAR2 ,
    p_item_type        IN VARCHAR2 DEFAULT NULL ,
    p_item_key         IN VARCHAR2 DEFAULT NULL ,
    p_age              IN NUMBER DEFAULT 0 ,
    p_attempt_to_close IN VARCHAR2 DEFAULT 'N' ,
    p_commit_frequency IN NUMBER DEFAULT 500 );
END OE_PURGE_WF;

/
