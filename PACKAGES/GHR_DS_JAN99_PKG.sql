--------------------------------------------------------
--  DDL for Package GHR_DS_JAN99_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_DS_JAN99_PKG" AUTHID CURRENT_USER AS
/* $Header: ghdsconv.pkh 120.0.12010000.3 2009/05/26 11:53:21 utokachi noship $ */

  PROCEDURE do_conversion(
                   p_errbuf out NOCOPY varchar2
                  ,p_retcode out NOCOPY number
                  ,p_old_location_id    IN     hr_locations.location_id%TYPE
                  ,p_new_location_id    IN     hr_locations.location_id%TYPE);

END ghr_ds_jan99_pkg;

/
