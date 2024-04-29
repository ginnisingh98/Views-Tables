--------------------------------------------------------
--  DDL for Package PO_RCOTOLERANCE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_RCOTOLERANCE_GRP" AUTHID CURRENT_USER AS
/* $Header: POXGRTWS.pls 120.1.12010000.2 2008/11/03 10:20:24 rojain ship $*/


PROCEDURE set_approval_required_flag(
  p_chreqgrp_id IN NUMBER
, x_appr_status OUT NOCOPY VARCHAR2
, p_source_type_code  IN VARCHAR2 DEFAULT NULL
);
END po_rcotolerance_grp;

/
