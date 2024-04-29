--------------------------------------------------------
--  DDL for Package HR_ADE_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ADE_UPGRADE" AUTHID CURRENT_USER AS
/* $Header: peadeupg.pkh 115.1 2002/11/22 17:07:43 apholt noship $ */
--
---------------------------- parse_ini_file -----------------------------
-- This process reads style setting from the ADE.ini file
-- creates output file with metadata suitable for upload to Web ADI
-- Will be run as a concurrent process
--
--  Input Parameters
--        p_file  - name of input file, normally ADE.INI
--
--  Output Parameters
--        errbuff - variable used by concurrent process manager
--        retcode - variable used by concurrent process manager
--
 PROCEDURE parse_ini_file(errbuff     OUT  NOCOPY VARCHAR2
                         ,retcode     OUT  NOCOPY NUMBER
                         ,p_file   IN     VARCHAR2);

END HR_ADE_UPGRADE;

 

/
