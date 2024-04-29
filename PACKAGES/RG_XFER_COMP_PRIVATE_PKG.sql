--------------------------------------------------------
--  DDL for Package RG_XFER_COMP_PRIVATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RG_XFER_COMP_PRIVATE_PKG" AUTHID CURRENT_USER as
/* $Header: rgixcpps.pls 120.3 2003/05/16 22:27:25 vtreiger ship $ */


PROCEDURE init(
            SourceCOAId NUMBER,
            TargetCOAId NUMBER,
            LinkName    VARCHAR2,
            ApplId      NUMBER);

PROCEDURE copy_axis_details(
            AxisSetType     VARCHAR2,
            AxisSetName     VARCHAR2,
            SourceAxisSetId NUMBER,
            TargetAxisSetId NUMBER);

PROCEDURE copy_column_set_header(
            SourceColumnSetId NUMBER,
            TargetColumnSetId NUMBER);

PROCEDURE copy_content_set_details(
            ContentSetName     VARCHAR2,
            SourceContentSetId NUMBER,
            TargetContentSetId NUMBER);

PROCEDURE get_element_target_id(
            SourceAxisSetId IN NUMBER,
            AxisSeq IN NUMBER,
            IdValue IN OUT NOCOPY VARCHAR2);

END RG_XFER_COMP_PRIVATE_PKG;

 

/
