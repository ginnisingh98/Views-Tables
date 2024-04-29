--------------------------------------------------------
--  DDL for Package PER_HRTCA_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_HRTCA_MERGE" AUTHID CURRENT_USER as
/* $Header: perhrtca.pkh 120.3.12010000.1 2008/07/28 05:43:02 appldev ship $ */
  --
  g_prev_last_name_len number default null;
  --
--bug no 5546586 starts here
  g_old_email_address        per_all_people_f.email_address%type;
--bug no 5546586 ends here

  TYPE g_party_id_type IS TABLE OF NUMBER(15) index by binary_integer;
  --
  procedure migrate_all_hr_persons
    (p_number_of_workers in number default 1,
     p_current_worker    in number default 1);
  --
  procedure migrate_all_hr_email
    (p_number_of_workers in number default 1,
     p_current_worker    in number default 1);
  --
  procedure migrate_all_hr_gender
    (p_number_of_workers in number default 1,
     p_current_worker    in number default 1);
  --
  procedure create_tca_person
    (p_rec                in out nocopy per_all_people_f%rowtype);
  --
  procedure update_tca_person
    (p_rec                in out nocopy per_all_people_f%rowtype,
     p_overwrite_data     in varchar2 default 'Y');
  --
  procedure replicate_person_across_bg
    (p_rec                in out nocopy per_all_people_f%rowtype,
     p_overwrite_data     in varchar2 default 'Y');
  --
  procedure create_update_contact_point
    (p_rec                in out nocopy per_all_people_f%rowtype);
  --
  procedure per_party_merge
    (p_entity_name        in  varchar2,
     p_from_id            in  number,
     p_to_id              out nocopy number,
     p_from_fk_id         in  number,
     p_to_fk_id           in  number,
     p_parent_entity_name in  varchar2,
     p_batch_id           in  number,
     p_batch_party_id     in  number,
     p_return_status      out nocopy varchar2);
  --
  -- ------------------------------------------------------------------------------
  -- |------------------------------< partyCleanup >------------------------------|
  -- ------------------------------------------------------------------------------
  --
  -- procedure to process a range of rowids and purge party data when
  -- required.
  --
    procedure partyCleanup(
      p_process_ctrl    IN            varchar2,
      p_start_rowid     IN            rowid,
      p_end_rowid       IN            rowid,
      p_rows_processed    OUT nocopy number);
  --
  -- ------------------------------------------------------------------------------
  -- |------------------------< partycleanup_full_conc >--------------------------|
  -- ------------------------------------------------------------------------------
  --
  procedure partycleanup_full_conc(errbuf        out NOCOPY  varchar2,
                                   retcode       out NOCOPY  varchar2
                                  );
  --
  --
  -- ------------------------------------------------------------------------------
  -- |------------------------< partycleanup_tca_conc >--------------------------|
  -- ------------------------------------------------------------------------------
  --
  procedure partycleanup_tca_conc(errbuf        out NOCOPY  varchar2,
                                  retcode       out NOCOPY  varchar2);
  --
  -- ------------------------------------------------------------------------------
  -- |------------------------< CHK_GUPUD_RUN_BOOLEAN >--------------------------|
  -- ------------------------------------------------------------------------------
  --
  procedure CHK_GUPUD_RUN_BOOLEAN(retstring     out NOCOPY  varchar2);
  --
  -- ----------------------------------------------------------------------------
  -- |----------------------------< get_party_details >-------------------------|
  -- ----------------------------------------------------------------------------
  -- {Start Of Comments}
  --
  -- Description:
  --   This function will return a single record for a given party id and
  --   effective date
  --
  -- Prerequisites:
  --   A valid record should be existing in per_all_people_f table for the
  --   given party id and effective date
  --
  -- In Parameters:
  --   Name                        Reqd   Type     Description
  --   p_party_id                  Yes    Number   Party identifier
  --   p_effective_date            Yes    Date     Effective date (Session date)
  --
  -- Post Success:
  --   A single record will be returned for the given party id and effective date
  --
  -- Post Failure:
  --   None
  --
  -- Access Status:
  --   Public.
  --
  -- {End Of Comments}
  --
  -- ---------------------------------------------------------------------------
    function get_party_details
      (p_party_id           in number,
       p_effective_date     in date) return per_per_shd.g_rec_type;
  --
  --
  -- ------------------------------------------------------------------------------
  -- |--------------------------< get_tca_merge_actions >-----------------------|
  -- ------------------------------------------------------------------------------
  --
  -- Description:
  --   This function will return an action to be performed. This function
  --   returns one of the following actions.
  --
  --        'CREATE PARTY'
  --        'AVOID CREATE PARTY'
  --        'PARTY VALID'
  --        'PARTY INVALID'
  --
  -- Prerequisites:
  --   A valid record should be existing in per_all_people_f table for the
  --   given party id and effective date
  --
  -- In Parameters:
  --   Name                        Reqd   Type     Description
  --   p_person_id                 Yes    Number   Person Identifier
  --   p_party_id                  Yes    Number   Party identifier
  --
  -- Post Success:
  --   Function returns actions to be performed depending upon the person_id,
  --   party_id and the system_person_type, at the end of time.
  --
  -- Post Failure:
  --   None
  --
  -- Access Status:
  --   Public.
  --
  -- {End Of Comments}
  --
  -- ---------------------------------------------------------------------------
  --
  FUNCTION get_tca_merge_actions
    (p_person_id  in number
    ,p_party_id   in number
    )
  RETURN VARCHAR2;
  --
  --
  -- ----------------------------------------------------------------------------
  -- |----------------------------< get_person_details >-------------------------|
  -- ----------------------------------------------------------------------------
  -- {Start Of Comments}
  --
  -- Description:
  --   This function will return a single record for a given party id, person_id and
  --   effective date
  --
  -- Prerequisites:
  --   A valid record should be existing in per_all_people_f table for the
  --   given party id,person id and effective date
  --
  -- In Parameters:
  --   Name                        Reqd   Type     Description
  --   p_party_id                  Yes    Number   Party identifier
  --   p_person_id                 Yes    Number   Person Identifier
  --   p_effective_date            Yes    Date     Effective date (Session date)
  --
  -- Post Success:
  --   A single record will be returned for the given party id,person_id and effective
  --   date
  --
  -- Post Failure:
  --   None
  --
  -- Access Status:
  --   Public.
  --
  -- {End Of Comments}
  --
  -- ---------------------------------------------------------------------------
  function get_person_details
           (p_party_id           in number,
            p_person_id          in number,
            p_effective_date     in date) return per_per_shd.g_rec_type;
  --
  --
  -- ----------------------------------------------------------------------------
  -- |-------------------------< migrate_all_hr_persons >-----------------------|
  -- ----------------------------------------------------------------------------
  -- {Start Of Comments}
  --
  -- Description:
  --   Procedure to update the party id for the valid persons.This is called from
  --   the upgrade script perhrtca3.sql.
  --
  -- Prerequisites:
  --   None
  --
  -- In Parameters:
  --   Name                        Reqd   Type     Description
  --   p_start_rowid               Yes    Rowid    Starting Person rowid in this range
  --   p_end_rowid                 Yes    Rowid    Final Person rowid in this range
  --
  -- Out Parameters:
  --   Name                        Reqd   Type     Description
  --   p_rows_processed            Yes    Number   Number of rows processed.
  --
  -- Post Success:
  --   Number of records processed will be assigned to p_row_processed.
  --
  -- Post Failure:
  --   None
  --
  -- Access Status:
  --   Public.
  --
  -- {End Of Comments}
  --
  -- ---------------------------------------------------------------------------
  procedure migrate_all_hr_persons(p_start_rowid in rowid,
                                 p_end_rowid in rowid,
                                 p_rows_processed out NOCOPY number);
  --
  -- ----------------------------------------------------------------------------
  -- |-------------------------< migrate_all_hr_email >-----------------------|
  -- ----------------------------------------------------------------------------
  -- {Start Of Comments}
  --
  -- Description:
  --   Procedure to migrate hr_email for the valid persons.This is called from
  --   the upgrade script peremtca2.sql.
  --
  -- Prerequisites:
  --   None
  --
  -- In Parameters:
  --   Name                        Reqd   Type     Description
  --   p_start_rowid               Yes    Rowid    Starting Person rowid in this range
  --   p_end_rowid                 Yes    Rowid    Final Person rowid in this range
  --
  -- Out Parameters:
  --   Name                        Reqd   Type     Description
  --   p_rows_processed            Yes    Number   Number of rows processed.
  --
  -- Post Success:
  --   Number of records processed will be assigned to p_row_processed.
  --
  -- Post Failure:
  --   None
  --
  -- Access Status:
  --   Public.
  --
  -- {End Of Comments}
  --
   procedure migrate_all_hr_email(p_start_rowid in rowid,
                                 p_end_rowid in rowid,
                                 p_rows_processed out NOCOPY number);
  --
  /* Added this for the bug 5395601  */
  Procedure purge_person(
			p_person_id  in number
		       ,p_party_id   in number
		        );
  --

end per_hrtca_merge;
--

/
