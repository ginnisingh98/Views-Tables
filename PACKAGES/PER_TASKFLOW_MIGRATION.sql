--------------------------------------------------------
--  DDL for Package PER_TASKFLOW_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_TASKFLOW_MIGRATION" AUTHID CURRENT_USER AS
/* $Header: petflupg.pkh 115.0 2003/05/09 13:44:24 pkakar noship $ */
--
procedure migrateNavUnitdata
            ( p_process_number   IN     varchar2
            , p_max_number_proc  IN     varchar2
            , p_param1           IN     varchar2
            , p_param2           IN     varchar2
            , p_param3           IN     varchar2
            , p_param4           IN     varchar2
            , p_param5           IN     varchar2
            , p_param6           IN     varchar2
            , p_param7           IN     varchar2
            , p_param8           IN     varchar2
            , p_param9           IN     varchar2
            , p_param10          IN     varchar2
            );

procedure migrateNavPathdata
            ( p_process_number   IN     varchar2
            , p_max_number_proc  IN     varchar2
            , p_param1           IN     varchar2
            , p_param2           IN     varchar2
            , p_param3           IN     varchar2
            , p_param4           IN     varchar2
            , p_param5           IN     varchar2
            , p_param6           IN     varchar2
            , p_param7           IN     varchar2
            , p_param8           IN     varchar2
            , p_param9           IN     varchar2
            , p_param10          IN     varchar2
            );

--
end per_taskflow_migration;

 

/
