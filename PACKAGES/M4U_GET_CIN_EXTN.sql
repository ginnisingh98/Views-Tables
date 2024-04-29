--------------------------------------------------------
--  DDL for Package M4U_GET_CIN_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."M4U_GET_CIN_EXTN" AUTHID CURRENT_USER AS
/* $Header: M4UCINXS.pls 120.0 2006/05/25 12:51:16 bsaratna noship $ */

        -- API corresponds to ecx xml framgent generation api signature
        -- send the parameters in wf_event.parameter_list
        -- retrive xml in x_xml
        -- Any failure is RAISEed and M4USTD workflow is stopped
        -- This api is called from m4u_230_cin_out.xgm extensions/extensionsHookTag
        PROCEDURE get_xml_fragment
        (
                a_evnt          IN              WF_EVENT_T,
                x_xml           OUT NOCOPY      VARCHAR2
        );
END m4u_get_cin_extn;

 

/
