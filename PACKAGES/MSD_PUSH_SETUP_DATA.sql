--------------------------------------------------------
--  DDL for Package MSD_PUSH_SETUP_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_PUSH_SETUP_DATA" AUTHID CURRENT_USER as
/* $Header: msdpstps.pls 115.3 2004/07/30 22:54:37 esubrama ship $ */
--
    Type para_profile is RECORD (
        profile_name            varchar2(30),
        parameter_value         varchar2(255),
        function_name           varchar2(61),
        DP_Server_flag          varchar2(1),
        function_profile_code   varchar2(1));

    Type para_profile_list is TABLE of para_profile index by binary_integer;
--

    Procedure Push_data (
        errbuf          OUT NOCOPY  varchar2,
        retcode         OUT NOCOPY  varchar2,
        p_instance_id   IN  number);


    procedure chk_push_setup(   errbuf         OUT  NOCOPY VARCHAR2,
                                retcode        OUT  NOCOPY VARCHAR2,
                                p_instance_id  IN   NUMBER );


End;

 

/
