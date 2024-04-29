--------------------------------------------------------
--  DDL for Package PER_HRWF_SYNCH_COVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_HRWF_SYNCH_COVER" AUTHID CURRENT_USER AS
/* $Header: perhrwfs.pkh 120.0.12010000.1 2008/07/28 05:43:09 appldev ship $ */
--
  --
  -- --------------------------------------------------------------------------
  -- |-----------------------------< per_pds_wf >-----------------------------|
  -- --------------------------------------------------------------------------
  --
  -- {Start Of Comments}
  --
  -- Description:
  --
  --   This procedure will act as a cover procedure for
  --   PER_HRWF_SYNCH.PER_PDS_WF
  --
  -- Pre Conditions:
  --   None.
  --
  -- In Arguments:
  --   p_person_id
  --   p_date
  --   p_date_start Start date of the period of employment
  --   p_action(TERMINATION, REVERSE TERMINATION)
  --
  -- Post Success:
  --   Calls the actual procedure PER_HRWF_SYNCH.PER_PDS_WF
  --
  -- Post Failure:
  --   None.
  --
  -- Access Status:
  --   Internal Table Handler Use Only.
  --
  -- {End Of Comments}
  -- ----------------------------------------------------------------------------
     procedure per_pds_wf(
               p_person_id            in number,
               p_date                 in date default null,
               p_date_start           in date,
               p_action               in varchar2);
  --
  -- --------------------------------------------------------------------------
  -- |-----------------------------< per_per_wf >-----------------------------|
  -- --------------------------------------------------------------------------
  --
  -- {Start Of Comments}
  --
  -- Description:
  --
  --   This procedure will act as a cover procedure for
  --   PER_HRWF_SYNCH.PER_PER_WF
  --
  -- Pre Conditions:
  --   None.
  --
  -- In Arguments:
  --   p_rec  per_per_shd.g_rec_type
  --   p_action(INSERT, DELETE, UPDATE).
  --
  -- Post Success:
  --   Calls the actual procedure PER_HRWF_SYNCH.PER_PER_WF
  --
  -- Post Failure:
  --   None.
  --
  -- Access Status:
  --   Internal Table Handler Use Only.
  --
  -- {End Of Comments}
  -- ----------------------------------------------------------------------------
     procedure per_per_wf(
               p_rec                  in per_per_shd.g_rec_type,
               p_action               in varchar2);

--
END PER_HRWF_SYNCH_COVER;

/
