--------------------------------------------------------
--  DDL for Package HR_XML_PUB_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_XML_PUB_UTILITY" AUTHID CURRENT_USER as
/* $Header: perxmlpb.pkh 120.0 2006/05/01 05:16 debhatta noship $ */

PROCEDURE clob_to_blob (p_clob clob,
                        p_blob IN OUT NOCOPY Blob);

END HR_XML_PUB_UTILITY;

 

/
