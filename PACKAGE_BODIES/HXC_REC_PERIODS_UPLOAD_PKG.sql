--------------------------------------------------------
--  DDL for Package Body HXC_REC_PERIODS_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_REC_PERIODS_UPLOAD_PKG" AS
/* $Header: hxchrpupl.pkb 115.5 2002/06/10 00:37:22 pkm ship      $ */

PROCEDURE load_recurring_period_row (
          p_name                IN VARCHAR2
        , p_start_date          IN VARCHAR2
        , p_end_date            IN VARCHAR2
        , p_period_type         IN VARCHAR2
        , p_duration_in_days    IN NUMBER
        , p_owner               IN VARCHAR2
        , p_custom_mode         IN VARCHAR2 ) IS

l_recurring_period_id	hxc_recurring_periods.recurring_period_id%TYPE;
l_ovn			hxc_recurring_periods.object_version_number%TYPE;
l_owner			VARCHAR2(6);

BEGIN

	SELECT	recurring_period_id
	       ,object_version_number
	       ,DECODE( NVL(last_updated_by,-1), 1, 'SEED', 'CUSTOM')
	INTO	l_recurring_period_id
	       ,l_ovn
	       ,l_owner
	FROM	hxc_recurring_periods
	WHERE	name	= p_name;

	IF (p_custom_mode = 'FORCE' OR p_owner = 'SEED') THEN
           hxc_recurring_periods_api.update_recurring_periods
               (p_validate              => false
               ,p_recurring_period_id   => l_recurring_period_id
               ,p_object_version_number => l_ovn
               ,p_name                  => p_name
               ,p_period_type           => p_period_type
               ,p_duration_in_days      => p_duration_in_days
               ,p_start_date            => to_date(p_start_date, 'DD-MM-YYYY')
               ,p_end_date              => to_date(p_end_date, 'DD-MM-YYYY')
               ,p_effective_date        => sysdate
               );

           /* Use API instead of Row Handler */
           /*
	   hxc_hrp_upd.upd
               (p_effective_date        => sysdate
	       ,p_recurring_period_id   => l_recurring_period_id
	       ,p_object_version_number => l_ovn
	       ,p_name                  => p_name
	       ,p_start_date            => to_date(p_start_date, 'DD-MM-YYYY')
	       ,p_end_date              => to_date(p_end_date, 'DD-MM-YYYY')
	       ,p_period_type           => p_period_type
	       ,p_duration_in_days      => p_duration_in_days);
           */

	END IF;

EXCEPTION WHEN NO_DATA_FOUND
THEN

   hxc_recurring_periods_api.create_recurring_periods
       (p_validate                      => false
       ,p_recurring_period_id           => l_recurring_period_id
       ,p_object_version_number         => l_ovn
       ,p_name                          => p_name
       ,p_period_type                   => p_period_type
       ,p_duration_in_days              => p_duration_in_days
       ,p_start_date                    => to_date(p_start_date, 'DD-MM-YYYY')
       ,p_end_date                      => to_date(p_end_date, 'DD-MM-YYYY')
       ,p_effective_date                => sysdate
       );

/* Use API instead of Row Handler */
/*
   hxc_hrp_ins.ins
       (p_effective_date         => sysdate
       ,p_name                   => p_name
       ,p_start_date             => to_date(p_start_date, 'DD-MM-YYYY')
       ,p_end_date               => to_date(p_end_date, 'DD-MM-YYYY')
       ,p_period_type            => p_period_type
       ,p_duration_in_days       => p_duration_in_days
       ,p_recurring_period_id    => l_recurring_period_id
       ,p_object_version_number  => l_ovn);
*/

END load_recurring_period_row;

END hxc_rec_periods_upload_pkg;

/
