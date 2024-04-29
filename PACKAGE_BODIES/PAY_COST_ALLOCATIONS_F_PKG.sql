--------------------------------------------------------
--  DDL for Package Body PAY_COST_ALLOCATIONS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_COST_ALLOCATIONS_F_PKG" as
/* $Header: pycsa01t.pkb 120.1 2005/10/04 05:27:56 pgongada noship $ */
--
  procedure insert_row(p_rowid             in out nocopy varchar2,
                       p_cost_allocation_id    in number,
                       p_effective_start_date  in date,
                       p_effective_end_date    in date,
                       p_business_group_id     in number,
                       p_cost_allocation_keyflex_id in number,
                       p_assignment_id         in number,
                       p_proportion            in number,
                       p_request_id            in number,
                       p_program_application_id in number,
                       p_program_id            in number,
                       p_program_update_date   in date) IS
  --
  begin
  --
    insert into PAY_COST_ALLOCATIONS_F
         ( COST_ALLOCATION_ID,
           EFFECTIVE_START_DATE,
           EFFECTIVE_END_DATE,
           BUSINESS_GROUP_ID,
           COST_ALLOCATION_KEYFLEX_ID,
           ASSIGNMENT_ID,
           PROPORTION,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE)
    values
         ( p_cost_allocation_id,
           p_effective_start_date,
           p_effective_end_date,
           p_business_group_id,
           p_cost_allocation_keyflex_id,
           p_assignment_id,
           p_proportion,
           p_request_id,
           p_program_application_id,
           p_program_id,
           p_program_update_date);
      --
    select rowid
    into   p_rowid
    from   PAY_COST_ALLOCATIONS_F
    where  COST_ALLOCATION_ID = p_cost_allocation_id
    and    EFFECTIVE_START_DATE = p_effective_start_date
    and    EFFECTIVE_END_DATE = p_effective_end_date;
      --
  end insert_row;
--
  procedure update_row(p_rowid                 in varchar2,
                       p_cost_allocation_id    in number,
                       p_effective_start_date  in date,
                       p_effective_end_date    in date,
                       p_business_group_id     in number,
                       p_cost_allocation_keyflex_id in number,
                       p_assignment_id         in number,
                       p_proportion            in number,
                       p_request_id            in number,
                       p_program_application_id in number,
                       p_program_id            in number,
                       p_program_update_date   in date) is
  begin
  --
    update PAY_COST_ALLOCATIONS_F
    set    COST_ALLOCATION_ID         = p_cost_allocation_id,
           EFFECTIVE_START_DATE       = p_effective_start_date,
           EFFECTIVE_END_DATE         = p_effective_end_date,
           BUSINESS_GROUP_ID          = p_business_group_id,
           COST_ALLOCATION_KEYFLEX_ID = p_cost_allocation_keyflex_id,
           ASSIGNMENT_ID              = p_assignment_id,
           PROPORTION                 = p_proportion,
           REQUEST_ID                 = p_request_id,
           PROGRAM_APPLICATION_ID     = p_program_application_id,
           PROGRAM_ID                 = p_program_id,
           PROGRAM_UPDATE_DATE        = p_program_update_date
    where  ROWID = p_rowid;
  --
  end update_row;
--
  procedure delete_row(p_rowid   in varchar2) is
  --
  begin
  --
    delete from PAY_COST_ALLOCATIONS_F
    where  ROWID = p_rowid;
  --
  end delete_row;
--
  procedure lock_row(p_rowid                   in varchar2,
                       p_cost_allocation_id    in number,
                       p_effective_start_date  in date,
                       p_effective_end_date    in date,
                       p_business_group_id     in number,
                       p_cost_allocation_keyflex_id in number,
                       p_assignment_id         in number,
                       p_proportion            in number,
                       p_request_id            in number,
                       p_program_application_id in number,
                       p_program_id            in number,
                       p_program_update_date   in date) is
  --
    cursor C is select *
                from   PAY_COST_ALLOCATIONS_F
                where  rowid = p_rowid
                for update of COST_ALLOCATION_ID nowait;
  --
    rowinfo  C%rowtype;
  --
  begin
  --
    open C;
    fetch C into rowinfo;
    close C;
    --
    if (   (  (rowinfo.COST_ALLOCATION_ID         = p_cost_allocation_id)
           or (rowinfo.COST_ALLOCATION_ID         is null and p_cost_allocation_id         is null))
       and (  (rowinfo.EFFECTIVE_START_DATE       = p_effective_start_date)
           or (rowinfo.EFFECTIVE_START_DATE       is null and p_effective_start_date       is null))
       and (  (rowinfo.EFFECTIVE_END_DATE         = p_effective_end_date)
           or (rowinfo.EFFECTIVE_END_DATE         is null and p_effective_end_date         is null))
       and (  (rowinfo.BUSINESS_GROUP_ID          = p_business_group_id)
           or (rowinfo.BUSINESS_GROUP_ID          is null and p_business_group_id          is null))
       and (  (rowinfo.COST_ALLOCATION_KEYFLEX_ID = p_cost_allocation_keyflex_id)
           or (rowinfo.COST_ALLOCATION_KEYFLEX_ID is null and p_cost_allocation_keyflex_id is null))
       and (  (rowinfo.ASSIGNMENT_ID              = p_assignment_id)
           or (rowinfo.ASSIGNMENT_ID              is null and p_assignment_id              is null))
       and (  (rowinfo.PROPORTION                 = p_proportion)
           or (rowinfo.PROPORTION                 is null and p_proportion                 is null))
       and (  (rowinfo.REQUEST_ID                 = p_request_id)
           or (rowinfo.REQUEST_ID                 is null and p_request_id                 is null))
       and (  (rowinfo.PROGRAM_APPLICATION_ID     = p_program_application_id)
           or (rowinfo.PROGRAM_APPLICATION_ID     is null and p_program_application_id     is null))
       and (  (rowinfo.PROGRAM_ID                 = p_program_id)
           or (rowinfo.PROGRAM_ID                 is null and p_program_id                 is null))
       and (  (rowinfo.PROGRAM_UPDATE_DATE        = p_program_update_date)
           or (rowinfo.PROGRAM_UPDATE_DATE        is null and p_program_update_date        is null))) then
       return;
    else
       fnd_message.set_name('FND','FORM_RECORD_CHANGED');
       app_exception.raise_exception;
    end if;
  end lock_row;
--
  procedure maintain_cost_keyflex(p_cost_keyflex_id in out nocopy number,
				  p_cost_keyflex_structure in varchar2,
				  p_cost_allocation_keyflex_id in number,
				  p_concatenated_segments in varchar2,
				  p_summary_flag in varchar2,
                                  p_start_date_active in date,
				  p_end_date_active in date,
				  p_segment1 in varchar2,
				  p_segment2 in varchar2,
                                  p_segment3 in varchar2,
				  p_segment4 in varchar2,
				  p_segment5 in varchar2,
				  p_segment6 in varchar2,
				  p_segment7 in varchar2,
                                  p_segment8 in varchar2,
				  p_segment9 in varchar2,
				  p_segment10 in varchar2,
				  p_segment11 in varchar2,
                                  p_segment12 in varchar2,
				  p_segment13 in varchar2,
				  p_segment14 in varchar2,
				  p_segment15 in varchar2,
                                  p_segment16 in varchar2,
				  p_segment17 in varchar2,
				  p_segment18 in varchar2,
				  p_segment19 in varchar2,
                                  p_segment20 in varchar2,
				  p_segment21 in varchar2,
				  p_segment22 in varchar2,
				  p_segment23 in varchar2,
                                  p_segment24 in varchar2,
				  p_segment25 in varchar2,
				  p_segment26 in varchar2,
				  p_segment27 in varchar2,
                                  p_segment28 in varchar2,
				  p_segment29 in varchar2,
				  p_segment30 in varchar2) is
--
begin
     -- This is a workaround as it is not possible to call this procedure from
     -- the client side.  Maybe a problem with incompatible PL/SQL versions
     -- If a keyflex field has been entered then check to see if a record exists
     -- with the segment values entered and retrieve its primary key value, else
     -- key flexfield or a new complete flexfield has been entered.
     --
     -- Bug fix 3561111
     -- Should pass null concatenated_segments into maintain_cost_keyflex to
     -- ensure concatenated_segments gets calculated correctly.
     -- The value passed from above is the from value - and will only be the
     -- segments qualified at this level concatenated together.
     --
     p_cost_keyflex_id :=
	  hr_entry.maintain_cost_keyflex(p_cost_keyflex_structure,
				    p_cost_allocation_keyflex_id,
				    null,
				    p_summary_flag,
				    p_start_date_active,
				    p_end_date_active,
				    p_segment1,
				    p_segment2,
				    p_segment3,
				    p_segment4,
				    p_segment5,
				    p_segment6,
				    p_segment7,
				    p_segment8,
				    p_segment9,
				    p_segment10,
				    p_segment11,
				    p_segment12,
				    p_segment13,
				    p_segment14,
				    p_segment15,
				    p_segment16,
				    p_segment17,
				    p_segment18,
				    p_segment19,
				    p_segment20,
				    p_segment21,
				    p_segment22,
				    p_segment23,
				    p_segment24,
				    p_segment25,
				    p_segment26,
				    p_segment27,
				    p_segment28,
				    p_segment29,
				    p_segment30);
--
end maintain_cost_keyflex;
end PAY_COST_ALLOCATIONS_F_PKG;

/
