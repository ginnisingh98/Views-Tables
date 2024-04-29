--------------------------------------------------------
--  DDL for Package PER_ABT_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ABT_MIGRATION" AUTHID CURRENT_USER AS
/* $Header: peabtmig.pkh 120.0 2005/05/31 04:47:56 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< migrateABTData >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure migrates rows from per_absence_attendnace_types to the
--   translation table per_abs_attendance_types_tl, creating a row for
--   each installed languages
--
procedure migrateABTData
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

end per_abt_migration;

 

/
