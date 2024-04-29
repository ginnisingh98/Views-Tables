--------------------------------------------------------
--  DDL for Package Body PER_PERIODS_OF_SERVICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERIODS_OF_SERVICE_PKG" AS
/* $Header: pepds01t.pkb 120.1 2005/11/03 06:25:01 bshukla noship $ */
----------------------------------------------------------------------------

----------------------------------------------------------------------------
procedure delete_per_pay_proposals(p_period_of_service_id number
                                  ,p_actual_termination_date date) is
--
cursor ass1 is select pa.assignment_id
                from per_assignments pa
                where pa.period_of_service_id = p_period_of_service_id;
--
-- VT #464380 05/14/97
cursor ppr1 (p_assignment_id_in number) is
	select pp.pay_proposal_id
	from per_pay_proposals pp
	where pp.assignment_id = p_assignment_id_in
	  and pp.change_date > p_actual_termination_date;
--
p_pay_proposal_id number;
--
p_assignment_id number;
--
begin
   open ass1;
   fetch ass1 into p_assignment_id;
   loop
      exit when ass1%notfound;
      -- VT #464380 05/14/97
        open ppr1(p_assignment_id);
        fetch ppr1 into p_pay_proposal_id;
        loop
          exit when ppr1%notfound;
          delete from per_pay_proposal_components ppc
          where ppc.pay_proposal_id = p_pay_proposal_id;
          fetch ppr1 into p_pay_proposal_id;
        end loop;
        close ppr1;
      --
      delete from per_pay_proposals
      where assignment_id = p_assignment_id
      and   change_date > p_actual_termination_date;
      --
      fetch ass1 into p_assignment_id;
   end loop;
   close ass1;
end delete_per_pay_proposals;
----------------------------------------------------------------------------
procedure get_years_months(p_session_date  IN DATE,
                           p_period_of_service_id IN NUMBER,
                           p_business_group_id    IN     NUMBER,
                           p_person_id            IN     NUMBER,
                           p_tp_years             IN OUT NOCOPY NUMBER,
                           p_tp_months            IN OUT NOCOPY NUMBER,
                           p_total_years          IN OUT NOCOPY NUMBER,
                           p_total_months         IN OUT NOCOPY NUMBER) is
--
 cursor C_TP1 is
  select trunc(months_between(least(nvl(ACTUAL_TERMINATION_DATE + 1, p_session_date + 1),
         p_session_date+ 1), DATE_START) / 12, 0) tp_years,
         trunc(mod(months_between(least(nvl(ACTUAL_TERMINATION_DATE + 1, p_session_date + 1),
             p_session_date + 1), DATE_START), 12) ,0) tp_months
  from   PER_PERIODS_OF_SERVICE
  where  DATE_START        <= p_session_date
  and    PERIOD_OF_SERVICE_ID = p_period_of_service_id;
--
 cursor C_TY1 is
  select trunc(sum(months_between(least(nvl(ACTUAL_TERMINATION_DATE + 1, p_session_date + 1),
              p_session_date + 1), DATE_START)) / 12 ,0) total_years,
         trunc(mod(sum(months_between(least(nvl(ACTUAL_TERMINATION_DATE + 1, p_session_date + 1),
                 p_session_date + 1), DATE_START)) , 12),0) total_months
  from   PER_PERIODS_OF_SERVICE
  where  PERSON_ID          = p_person_id
  and    business_group_id + 0  = p_business_group_id
  and    DATE_START        <= p_session_date
  and    PERIOD_OF_SERVICE_ID <= p_period_of_service_id;
--
begin
--
 open C_TP1;
 fetch C_TP1 into p_tp_years,
                  p_tp_months;
 close C_TP1;
 --
 open C_TY1;
 fetch C_TY1 into p_total_years,
                  p_total_months;
 close C_TY1;
 --
end get_years_months;
----------------------------------------------------------------------------
procedure get_final_dates(p_period_of_service_id NUMBER,
                         p_person_id NUMBER,
                         p_actual_termination_date DATE,
                         p_no_payrolls IN OUT NOCOPY NUMBER,
                         p_final_process_date IN OUT NOCOPY DATE,
                         p_last_standard_process_date IN OUT NOCOPY DATE) is
--
-- Get the number of payrolls person is assigned to
-- and the maximum last dates of the current time period
-- for the person's assignment.
--
begin
  select count(distinct(payroll_id))
  into p_no_payrolls
  from per_assignments pa
  where pa.period_of_service_id = p_period_of_service_id
  and pa.person_id = p_person_id;
  --
  --
  select max(end_date),max(end_date)
  into p_final_process_date
  ,    p_last_standard_process_date
  from per_time_periods
  where p_actual_termination_date between
    start_date and end_date
    and payroll_id in (select payroll_id
                     from per_assignments pa
                    where pa.period_of_service_id = p_period_of_service_id
                    and pa.person_id = p_person_id);
  --
  --
end get_final_dates;
----------------------------------------------------------------------------
procedure delete_row(p_row_id VARCHAR2) is
--
begin
--
delete from per_periods_of_service
where rowid=chartorowid(p_row_id);
--
end;
--
procedure insert_row(p_row_id in out nocopy VARCHAR2
,p_period_of_service_id           in out nocopy NUMBER
,p_business_group_id              NUMBER
,p_person_id                      NUMBER
,p_date_start                     DATE
,p_termination_accepted_per_id NUMBER
,p_accepted_termination_date      DATE
,p_actual_termination_date        DATE
,p_comments                       VARCHAR2
,p_final_process_date             DATE
,p_last_standard_process_date     DATE
,p_leaving_reason                 VARCHAR2
,p_notified_termination_date      DATE
,p_projected_termination_date     DATE
,p_request_id                     NUMBER
,p_program_application_id         NUMBER
,p_program_id                     NUMBER
,p_program_update_date            DATE
,p_attribute_category             VARCHAR2
,p_attribute1                     VARCHAR2
,p_attribute2                     VARCHAR2
,p_attribute3                     VARCHAR2
,p_attribute4                     VARCHAR2
,p_attribute5                     VARCHAR2
,p_attribute6                     VARCHAR2
,p_attribute7                     VARCHAR2
,p_attribute8                     VARCHAR2
,p_attribute9                     VARCHAR2
,p_attribute10                    VARCHAR2
,p_attribute11                    VARCHAR2
,p_attribute12                    VARCHAR2
,p_attribute13                    VARCHAR2
,p_attribute14                    VARCHAR2
,p_attribute15                    VARCHAR2
,p_attribute16                    VARCHAR2
,p_attribute17                    VARCHAR2
,p_attribute18                    VARCHAR2
,p_attribute19                    VARCHAR2
,p_attribute20                    VARCHAR2
,p_adjusted_svc_date              DATE
) is
l_period_of_service_id NUMBER(15);
--
-- START WWBUG fix for 1390173
--
l_old   ben_pps_ler.g_pps_ler_rec;
l_new   ben_pps_ler.g_pps_ler_rec;
--
-- END WWBUG fix for 1390173
--
begin
begin
select per_periods_of_service_s.nextval
into   l_period_of_service_id
from sys.dual;
end;
insert into per_periods_of_service (
period_of_service_id
,business_group_id
,person_id
,date_start
,termination_accepted_person_id
,accepted_termination_date
,actual_termination_date
,comments
,final_process_date
,last_standard_process_date
,leaving_reason
,notified_termination_date
,projected_termination_date
,request_id
,program_application_id
,program_id
,program_update_date
,attribute_category
,attribute1
,attribute2
,attribute3
,attribute4
,attribute5
,attribute6
,attribute7
,attribute8
,attribute9
,attribute10
,attribute11
,attribute12
,attribute13
,attribute14
,attribute15
,attribute16
,attribute17
,attribute18
,attribute19
,attribute20
,adjusted_svc_date
)
values(
l_period_of_service_id
,p_business_group_id
,p_person_id
,p_date_start
,p_termination_accepted_per_id
,p_accepted_termination_date
,p_actual_termination_date
,p_comments
,p_final_process_date
,p_last_standard_process_date
,p_leaving_reason
,p_notified_termination_date
,p_projected_termination_date
,p_request_id
,p_program_application_id
,p_program_id
,p_program_update_date
,p_attribute_category
,p_attribute1
,p_attribute2
,p_attribute3
,p_attribute4
,p_attribute5
,p_attribute6
,p_attribute7
,p_attribute8
,p_attribute9
,p_attribute10
,p_attribute11
,p_attribute12
,p_attribute13
,p_attribute14
,p_attribute15
,p_attribute16
,p_attribute17
,p_attribute18
,p_attribute19
,p_attribute20
,p_adjusted_svc_date
);
--
-- START WWBUG fix for 1390173
--
l_new.PERSON_ID := p_person_id;
l_new.BUSINESS_GROUP_ID := p_business_group_id;
l_new.DATE_START := p_date_start;
l_new.ACTUAL_TERMINATION_DATE := p_actual_termination_date;
l_new.LEAVING_REASON := p_leaving_reason;
l_new.ADJUSTED_SVC_DATE := p_adjusted_svc_date;
l_new.ATTRIBUTE1 := p_attribute1;
l_new.ATTRIBUTE2 := p_attribute2;
l_new.ATTRIBUTE3 := p_attribute3;
l_new.ATTRIBUTE4 := p_attribute4;
l_new.ATTRIBUTE5 := p_attribute5;
l_new.final_process_date := p_final_process_date;
--
ben_pps_ler.ler_chk(p_old            => l_old
                   ,p_new            => l_new
                   ,p_event          => 'INSERTING'
                   ,p_effective_date => p_date_start);
--
-- END WWBUG fix for 1390173
--
--
p_period_of_service_id := l_period_of_service_id;
end;
----------------------------------------------------------------------------
procedure lock_row(p_row_id VARCHAR2
,p_period_of_service_id           NUMBER
,p_business_group_id              NUMBER
,p_person_id                      NUMBER
,p_date_start                     DATE
,p_termination_accepted_per_id NUMBER
,p_accepted_termination_date      DATE
,p_actual_termination_date        DATE
,p_comments                       VARCHAR2
,p_final_process_date             DATE
,p_last_standard_process_date     DATE
,p_leaving_reason                 VARCHAR2
,p_notified_termination_date      DATE
,p_projected_termination_date     DATE
,p_request_id                     NUMBER
,p_program_application_id         NUMBER
,p_program_id                     NUMBER
,p_program_update_date            DATE
,p_attribute_category             VARCHAR2
,p_attribute1                     VARCHAR2
,p_attribute2                     VARCHAR2
,p_attribute3                     VARCHAR2
,p_attribute4                     VARCHAR2
,p_attribute5                     VARCHAR2
,p_attribute6                     VARCHAR2
,p_attribute7                     VARCHAR2
,p_attribute8                     VARCHAR2
,p_attribute9                     VARCHAR2
,p_attribute10                    VARCHAR2
,p_attribute11                    VARCHAR2
,p_attribute12                    VARCHAR2
,p_attribute13                    VARCHAR2
,p_attribute14                    VARCHAR2
,p_attribute15                    VARCHAR2
,p_attribute16                    VARCHAR2
,p_attribute17                    VARCHAR2
,p_attribute18                    VARCHAR2
,p_attribute19                    VARCHAR2
,p_attribute20                    VARCHAR2
,p_pds_information_category       VARCHAR2
,p_pds_information1               VARCHAR2
,p_pds_information2               VARCHAR2
,p_pds_information3               VARCHAR2
,p_pds_information4               VARCHAR2
,p_pds_information5               VARCHAR2
,p_pds_information6               VARCHAR2
,p_pds_information7               VARCHAR2
,p_pds_information8               VARCHAR2
,p_pds_information9               VARCHAR2
,p_pds_information10              VARCHAR2
,p_pds_information11              VARCHAR2
,p_pds_information12              VARCHAR2
,p_pds_information13              VARCHAR2
,p_pds_information14              VARCHAR2
,p_pds_information15              VARCHAR2
,p_pds_information16              VARCHAR2
,p_pds_information17              VARCHAR2
,p_pds_information18              VARCHAR2
,p_pds_information19              VARCHAR2
,p_pds_information20              VARCHAR2
,p_pds_information21              VARCHAR2
,p_pds_information22              VARCHAR2
,p_pds_information23              VARCHAR2
,p_pds_information24              VARCHAR2
,p_pds_information25              VARCHAR2
,p_pds_information26              VARCHAR2
,p_pds_information27              VARCHAR2
,p_pds_information28              VARCHAR2
,p_pds_information29              VARCHAR2
,p_pds_information30              VARCHAR2
,p_adjusted_svc_date              DATE
) is
cursor pps is select *
from per_periods_of_service
where rowid = chartorowid(p_row_id)
for update nowait;
pps_rec pps%rowtype;
begin
/*
hr_utility.trace_on(1,'james');
*/
   open pps;
      fetch pps into pps_rec;
   close pps;
   --
   -- Rtrim all character fields
   --
   pps_rec.attribute10 := rtrim(pps_rec.attribute10);
   pps_rec.attribute11 := rtrim(pps_rec.attribute11);
   pps_rec.attribute12 := rtrim(pps_rec.attribute12);
   pps_rec.attribute13 := rtrim(pps_rec.attribute13);
   pps_rec.attribute14 := rtrim(pps_rec.attribute14);
   pps_rec.attribute15 := rtrim(pps_rec.attribute15);
   pps_rec.attribute16 := rtrim(pps_rec.attribute16);
   pps_rec.attribute17 := rtrim(pps_rec.attribute17);
   pps_rec.attribute18 := rtrim(pps_rec.attribute18);
   pps_rec.attribute19 := rtrim(pps_rec.attribute19);
   pps_rec.attribute20 := rtrim(pps_rec.attribute20);
   pps_rec.comments := rtrim(pps_rec.comments);
   pps_rec.leaving_reason := rtrim(pps_rec.leaving_reason);
   pps_rec.attribute_category := rtrim(pps_rec.attribute_category);
   pps_rec.attribute1 := rtrim(pps_rec.attribute1);
   pps_rec.attribute2 := rtrim(pps_rec.attribute2);
   pps_rec.attribute3 := rtrim(pps_rec.attribute3);
   pps_rec.attribute4 := rtrim(pps_rec.attribute4);
   pps_rec.attribute5 := rtrim(pps_rec.attribute5);
   pps_rec.attribute6 := rtrim(pps_rec.attribute6);
   pps_rec.attribute7 := rtrim(pps_rec.attribute7);
   pps_rec.attribute8 := rtrim(pps_rec.attribute8);
   pps_rec.attribute9 := rtrim(pps_rec.attribute9);
   pps_rec.pds_information_category := rtrim(pps_rec.pds_information_category);
   pps_rec.pds_information1  := rtrim(pps_rec.pds_information1);
   pps_rec.pds_information2  := rtrim(pps_rec.pds_information2);
   pps_rec.pds_information3  := rtrim(pps_rec.pds_information3);
   pps_rec.pds_information4  := rtrim(pps_rec.pds_information4);
   pps_rec.pds_information5  := rtrim(pps_rec.pds_information5);
   pps_rec.pds_information6  := rtrim(pps_rec.pds_information6);
   pps_rec.pds_information7  := rtrim(pps_rec.pds_information7);
   pps_rec.pds_information8  := rtrim(pps_rec.pds_information8);
   pps_rec.pds_information9  := rtrim(pps_rec.pds_information9);
   pps_rec.pds_information10 := rtrim(pps_rec.pds_information10);
   pps_rec.pds_information11 := rtrim(pps_rec.pds_information11);
   pps_rec.pds_information12 := rtrim(pps_rec.pds_information12);
   pps_rec.pds_information13 := rtrim(pps_rec.pds_information13);
   pps_rec.pds_information14 := rtrim(pps_rec.pds_information14);
   pps_rec.pds_information15 := rtrim(pps_rec.pds_information15);
   pps_rec.pds_information16 := rtrim(pps_rec.pds_information16);
   pps_rec.pds_information17 := rtrim(pps_rec.pds_information17);
   pps_rec.pds_information18 := rtrim(pps_rec.pds_information18);
   pps_rec.pds_information19 := rtrim(pps_rec.pds_information19);
   pps_rec.pds_information20 := rtrim(pps_rec.pds_information20);
   pps_rec.pds_information21 := rtrim(pps_rec.pds_information21);
   pps_rec.pds_information22 := rtrim(pps_rec.pds_information22);
   pps_rec.pds_information23 := rtrim(pps_rec.pds_information23);
   pps_rec.pds_information24 := rtrim(pps_rec.pds_information24);
   pps_rec.pds_information25 := rtrim(pps_rec.pds_information25);
   pps_rec.pds_information26 := rtrim(pps_rec.pds_information26);
   pps_rec.pds_information27 := rtrim(pps_rec.pds_information27);
   pps_rec.pds_information28 := rtrim(pps_rec.pds_information28);
   pps_rec.pds_information29 := rtrim(pps_rec.pds_information29);
   pps_rec.pds_information30 := rtrim(pps_rec.pds_information30);
   pps_rec.adjusted_svc_date := rtrim(pps_rec.adjusted_svc_date);
   --
   if( (( p_period_of_service_id = pps_rec.period_of_service_id)
   or (pps_rec.period_of_service_id is null
   and (p_period_of_service_id is null)))
   and (( p_business_group_id = pps_rec.business_group_id)
   or (pps_rec.business_group_id is null
   and (p_business_group_id is null)))
   and (( p_person_id = pps_rec.person_id)
   or (pps_rec.person_id is null
   and (p_person_id is null)))
   and (( p_date_start = pps_rec.date_start)
   or (pps_rec.date_start is null
   and (p_date_start is null)))
   and (( p_termination_accepted_per_id =
        pps_rec.termination_accepted_person_id)
   or (pps_rec.termination_accepted_person_id is null
   and (p_termination_accepted_per_id is null)))
   and (( p_accepted_termination_date = pps_rec.accepted_termination_date)
   or (pps_rec.accepted_termination_date is null
   and (p_accepted_termination_date is null)))
   and (( p_actual_termination_date = pps_rec.actual_termination_date)
   or (pps_rec.actual_termination_date is null
   and (p_actual_termination_date is null)))
   and (( p_comments = pps_rec.comments)
   or (pps_rec.comments is null
   and (p_comments is null)))
   and (( p_final_process_date = pps_rec.final_process_date)
   or (pps_rec.final_process_date is null
   and (p_final_process_date is null)))
   and (( p_last_standard_process_date = pps_rec.last_standard_process_date)
   or (pps_rec.last_standard_process_date is null
   and (p_last_standard_process_date is null)))
   and (( p_leaving_reason = pps_rec.leaving_reason)
   or (pps_rec.leaving_reason is null
   and (p_leaving_reason is null)))
   and (( p_notified_termination_date = pps_rec.notified_termination_date)
   or (pps_rec.notified_termination_date is null
   and (p_notified_termination_date is null)))
   and (( p_projected_termination_date = pps_rec.projected_termination_date)
   or (pps_rec.projected_termination_date is null
   and (p_projected_termination_date is null)))
   and (( p_request_id = pps_rec.request_id)
   or (pps_rec.request_id is null
   and (p_request_id is null)))
   and (( p_program_application_id = pps_rec.program_application_id)
   or (pps_rec.program_application_id is null
   and (p_program_application_id is null)))
   and (( p_program_id = pps_rec.program_id)
   or (pps_rec.program_id is null
   and (p_program_id is null)))
   and (( p_program_update_date = pps_rec.program_update_date)
   or (pps_rec.program_update_date is null
   and (p_program_update_date is null)))
   and (( p_attribute_category = pps_rec.attribute_category)
   or (pps_rec.attribute_category is null
   and (p_attribute_category is null)))
   and (( p_attribute1 = pps_rec.attribute1)
   or (pps_rec.attribute1 is null
   and (p_attribute1 is null)))
   and (( p_attribute2 = pps_rec.attribute2)
   or (pps_rec.attribute2 is null
   and (p_attribute2 is null)))
   and (( p_attribute3 = pps_rec.attribute3)
   or (pps_rec.attribute3 is null
   and (p_attribute3 is null)))
   and (( p_attribute4 = pps_rec.attribute4)
   or (pps_rec.attribute4 is null
   and (p_attribute4 is null)))
   and (( p_attribute5 = pps_rec.attribute5)
   or (pps_rec.attribute5 is null
   and (p_attribute5 is null)))
   and (( p_attribute6 = pps_rec.attribute6)
   or (pps_rec.attribute6 is null
   and (p_attribute6 is null)))
   and (( p_attribute7 = pps_rec.attribute7)
   or (pps_rec.attribute7 is null
   and (p_attribute7 is null)))
   and (( p_attribute8 = pps_rec.attribute8)
   or (pps_rec.attribute8 is null
   and (p_attribute8 is null)))
   and (( p_attribute9 = pps_rec.attribute9)
   or (pps_rec.attribute9 is null
   and (p_attribute9 is null)))
   and (( p_attribute10 = pps_rec.attribute10)
   or (pps_rec.attribute10 is null
   and (p_attribute10 is null)))
   and (( p_attribute11 = pps_rec.attribute11)
   or (pps_rec.attribute11 is null
   and (p_attribute11 is null)))
   and (( p_attribute12 = pps_rec.attribute12)
   or (pps_rec.attribute12 is null
   and (p_attribute12 is null)))
   and (( p_attribute13 = pps_rec.attribute13)
   or (pps_rec.attribute13 is null
   and (p_attribute13 is null)))
   and (( p_attribute14 = pps_rec.attribute14)
   or (pps_rec.attribute14 is null
   and (p_attribute14 is null)))
   and (( p_attribute15 = pps_rec.attribute15)
   or (pps_rec.attribute15 is null
   and (p_attribute15 is null)))
   and (( p_attribute16 = pps_rec.attribute16)
   or (pps_rec.attribute16 is null
   and (p_attribute16 is null)))
   and (( p_attribute17 = pps_rec.attribute17)
   or (pps_rec.attribute17 is null
   and (p_attribute17 is null)))
   and (( p_attribute18 = pps_rec.attribute18)
   or (pps_rec.attribute18 is null
   and (p_attribute18 is null)))
   and (( p_attribute19 = pps_rec.attribute19)
   or (pps_rec.attribute19 is null
   and (p_attribute19 is null)))
   and (( p_attribute20 = pps_rec.attribute20)
   or (pps_rec.attribute20 is null
   and (p_attribute20 is null)))
   and (( p_pds_information_category = pps_rec.pds_information_category)
   or (pps_rec.pds_information_category is null
   and (p_pds_information_category is null)))
   and (( p_pds_information1 = pps_rec.pds_information1)
   or (pps_rec.pds_information1 is null
   and (p_pds_information1 is null)))
   and (( p_pds_information2 = pps_rec.pds_information2)
   or (pps_rec.pds_information2 is null
   and (p_pds_information2 is null)))
   and (( p_pds_information3 = pps_rec.pds_information3)
   or (pps_rec.pds_information3 is null
   and (p_pds_information3 is null)))
   and (( p_pds_information4 = pps_rec.pds_information4)
   or (pps_rec.pds_information4 is null
   and (p_pds_information4 is null)))
   and (( p_pds_information5 = pps_rec.pds_information5)
   or (pps_rec.pds_information5 is null
   and (p_pds_information5 is null)))
   and (( p_pds_information6 = pps_rec.pds_information6)
   or (pps_rec.pds_information6 is null
   and (p_pds_information6 is null)))
   and (( p_pds_information7 = pps_rec.pds_information7)
   or (pps_rec.pds_information7 is null
   and (p_pds_information7 is null)))
   and (( p_pds_information8 = pps_rec.pds_information8)
   or (pps_rec.pds_information8 is null
   and (p_pds_information8 is null)))
   and (( p_pds_information9 = pps_rec.pds_information9)
   or (pps_rec.pds_information9 is null
   and (p_pds_information9 is null)))
   and (( p_pds_information10 = pps_rec.pds_information10)
   or (pps_rec.pds_information10 is null
   and (p_pds_information10 is null)))
   and (( p_pds_information11 = pps_rec.pds_information11)
   or (pps_rec.pds_information11 is null
   and (p_pds_information11 is null)))
   and (( p_pds_information12 = pps_rec.pds_information12)
   or (pps_rec.pds_information12 is null
   and (p_pds_information12 is null)))
   and (( p_pds_information13 = pps_rec.pds_information13)
   or (pps_rec.pds_information13 is null
   and (p_pds_information13 is null)))
   and (( p_pds_information14 = pps_rec.pds_information14)
   or (pps_rec.pds_information14 is null
   and (p_pds_information14 is null)))
   and (( p_pds_information15 = pps_rec.pds_information15)
   or (pps_rec.pds_information15 is null
   and (p_pds_information15 is null)))
   and (( p_pds_information16 = pps_rec.pds_information16)
   or (pps_rec.pds_information16 is null
   and (p_pds_information16 is null)))
   and (( p_pds_information17 = pps_rec.pds_information17)
   or (pps_rec.pds_information17 is null
   and (p_pds_information17 is null)))
   and (( p_pds_information18 = pps_rec.pds_information18)
   or (pps_rec.pds_information18 is null
   and (p_pds_information18 is null)))
   and (( p_pds_information19 = pps_rec.pds_information19)
   or (pps_rec.pds_information19 is null
   and (p_pds_information19 is null)))
   and (( p_pds_information20 = pps_rec.pds_information20)
   or (pps_rec.pds_information20 is null
   and (p_pds_information20 is null)))
   and (( p_pds_information21 = pps_rec.pds_information21)
   or (pps_rec.pds_information21 is null
   and (p_pds_information21 is null)))
   and (( p_pds_information22 = pps_rec.pds_information22)
   or (pps_rec.pds_information22 is null
   and (p_pds_information22 is null)))
   and (( p_pds_information23 = pps_rec.pds_information23)
   or (pps_rec.pds_information23 is null
   and (p_pds_information23 is null)))
   and (( p_pds_information24 = pps_rec.pds_information24)
   or (pps_rec.pds_information24 is null
   and (p_pds_information24 is null)))
   and (( p_pds_information25 = pps_rec.pds_information25)
   or (pps_rec.pds_information25 is null
   and (p_pds_information25 is null)))
   and (( p_pds_information26 = pps_rec.pds_information26)
   or (pps_rec.pds_information26 is null
   and (p_pds_information26 is null)))
   and (( p_pds_information27 = pps_rec.pds_information27)
   or (pps_rec.pds_information27 is null
   and (p_pds_information27 is null)))
   and (( p_pds_information28 = pps_rec.pds_information28)
   or (pps_rec.pds_information28 is null
   and (p_pds_information28 is null)))
   and (( p_pds_information29 = pps_rec.pds_information29)
   or (pps_rec.pds_information29 is null
   and (p_pds_information29 is null)))
   and (( p_pds_information30 = pps_rec.pds_information30)
   or (pps_rec.pds_information30 is null
   and (p_pds_information30 is null)))
   and ((p_adjusted_svc_date = pps_rec.adjusted_svc_date)
   or (pps_rec.adjusted_svc_date is null
   and (p_adjusted_svc_date is null)))
   ) then
    return;
   end if;
/*
hr_utility.trace_off;
*/
   -- Record chaged by anothers user.
   fnd_message.set_name('FND','FORM_RECORD_CHANGED');
   app_exception.raise_exception ;
   exception when no_data_found then
      raise;
   when others then raise;
end lock_row;
----------------------------------------------------------------------------
procedure update_term_row(p_row_id VARCHAR2
,p_period_of_service_id           NUMBER
,p_business_group_id              NUMBER
,p_person_id                      NUMBER
,p_date_start                     DATE
,p_termination_accepted_per_id NUMBER
,p_accepted_termination_date      DATE
,p_actual_termination_date        DATE
,p_comments                       VARCHAR2
,p_final_process_date             DATE
,p_last_standard_process_date     DATE
,p_leaving_reason                 VARCHAR2
,p_notified_termination_date      DATE
,p_projected_termination_date     DATE
,p_request_id                     NUMBER
,p_program_application_id         NUMBER
,p_program_id                     NUMBER
,p_program_update_date            DATE
,p_attribute_category             VARCHAR2
,p_attribute1                     VARCHAR2
,p_attribute2                     VARCHAR2
,p_attribute3                     VARCHAR2
,p_attribute4                     VARCHAR2
,p_attribute5                     VARCHAR2
,p_attribute6                     VARCHAR2
,p_attribute7                     VARCHAR2
,p_attribute8                     VARCHAR2
,p_attribute9                     VARCHAR2
,p_attribute10                    VARCHAR2
,p_attribute11                    VARCHAR2
,p_attribute12                    VARCHAR2
,p_attribute13                    VARCHAR2
,p_attribute14                    VARCHAR2
,p_attribute15                    VARCHAR2
,p_attribute16                    VARCHAR2
,p_attribute17                    VARCHAR2
,p_attribute18                    VARCHAR2
,p_attribute19                    VARCHAR2
,p_attribute20                    VARCHAR2
,p_initiate_cancellation          VARCHAR2
,p_s_final_process_date IN OUT NOCOPY    DATE
,p_s_actual_termination_date IN OUT NOCOPY DATE
,p_c_assignment_status_type_id IN OUT NOCOPY NUMBER
,p_d_status                       VARCHAR2
,p_requery_required        IN OUT NOCOPY VARCHAR2
,p_clear_details  VARCHAR2 DEFAULT 'N'
,p_legislation_code               VARCHAR2
,p_pds_information_category       VARCHAR2
,p_pds_information1               VARCHAR2
,p_pds_information2               VARCHAR2
,p_pds_information3               VARCHAR2
,p_pds_information4               VARCHAR2
,p_pds_information5               VARCHAR2
,p_pds_information6               VARCHAR2
,p_pds_information7               VARCHAR2
,p_pds_information8               VARCHAR2
,p_pds_information9               VARCHAR2
,p_pds_information10              VARCHAR2
,p_pds_information11              VARCHAR2
,p_pds_information12              VARCHAR2
,p_pds_information13              VARCHAR2
,p_pds_information14              VARCHAR2
,p_pds_information15              VARCHAR2
,p_pds_information16              VARCHAR2
,p_pds_information17              VARCHAR2
,p_pds_information18              VARCHAR2
,p_pds_information19              VARCHAR2
,p_pds_information20              VARCHAR2
,p_pds_information21              VARCHAR2
,p_pds_information22              VARCHAR2
,p_pds_information23              VARCHAR2
,p_pds_information24              VARCHAR2
,p_pds_information25              VARCHAR2
,p_pds_information26              VARCHAR2
,p_pds_information27              VARCHAR2
,p_pds_information28              VARCHAR2
,p_pds_information29              VARCHAR2
,p_pds_information30              VARCHAR2
,p_adjusted_svc_date              DATE) is

p_dodwarning varchar2(1);

begin update_term_row
(p_row_id
,p_period_of_service_id
,p_business_group_id
,p_person_id
,p_date_start
,p_termination_accepted_per_id
,p_accepted_termination_date
,p_actual_termination_date
,p_comments
,p_final_process_date
,p_last_standard_process_date
,p_leaving_reason
,p_notified_termination_date
,p_projected_termination_date
,p_request_id
,p_program_application_id
,p_program_id
,p_program_update_date
,p_attribute_category
,p_attribute1
,p_attribute2
,p_attribute3
,p_attribute4
,p_attribute5
,p_attribute6
,p_attribute7
,p_attribute8
,p_attribute9
,p_attribute10
,p_attribute11
,p_attribute12
,p_attribute13
,p_attribute14
,p_attribute15
,p_attribute16
,p_attribute17
,p_attribute18
,p_attribute19
,p_attribute20
,p_initiate_cancellation
,p_s_final_process_date
,p_s_actual_termination_date
,p_c_assignment_status_type_id
,p_d_status
,p_requery_required
,p_clear_details
,p_legislation_code
,p_pds_information_category
,p_pds_information1
,p_pds_information2
,p_pds_information3
,p_pds_information4
,p_pds_information5
,p_pds_information6
,p_pds_information7
,p_pds_information8
,p_pds_information9
,p_pds_information10
,p_pds_information11
,p_pds_information12
,p_pds_information13
,p_pds_information14
,p_pds_information15
,p_pds_information16
,p_pds_information17
,p_pds_information18
,p_pds_information19
,p_pds_information20
,p_pds_information21
,p_pds_information22
,p_pds_information23
,p_pds_information24
,p_pds_information25
,p_pds_information26
,p_pds_information27
,p_pds_information28
,p_pds_information29
,p_pds_information30
,p_adjusted_svc_date
,p_dodwarning
);
--
end;
--
procedure update_term_row(p_row_id VARCHAR2
,p_period_of_service_id           NUMBER
,p_business_group_id              NUMBER
,p_person_id                      NUMBER
,p_date_start                     DATE
,p_termination_accepted_per_id NUMBER
,p_accepted_termination_date      DATE
,p_actual_termination_date        DATE
,p_comments                       VARCHAR2
,p_final_process_date             DATE
,p_last_standard_process_date     DATE
,p_leaving_reason                 VARCHAR2
,p_notified_termination_date      DATE
,p_projected_termination_date     DATE
,p_request_id                     NUMBER
,p_program_application_id         NUMBER
,p_program_id                     NUMBER
,p_program_update_date            DATE
,p_attribute_category             VARCHAR2
,p_attribute1                     VARCHAR2
,p_attribute2                     VARCHAR2
,p_attribute3                     VARCHAR2
,p_attribute4                     VARCHAR2
,p_attribute5                     VARCHAR2
,p_attribute6                     VARCHAR2
,p_attribute7                     VARCHAR2
,p_attribute8                     VARCHAR2
,p_attribute9                     VARCHAR2
,p_attribute10                    VARCHAR2
,p_attribute11                    VARCHAR2
,p_attribute12                    VARCHAR2
,p_attribute13                    VARCHAR2
,p_attribute14                    VARCHAR2
,p_attribute15                    VARCHAR2
,p_attribute16                    VARCHAR2
,p_attribute17                    VARCHAR2
,p_attribute18                    VARCHAR2
,p_attribute19                    VARCHAR2
,p_attribute20                    VARCHAR2
,p_initiate_cancellation          VARCHAR2
,p_s_final_process_date IN OUT NOCOPY    DATE
,p_s_actual_termination_date IN OUT NOCOPY DATE
,p_c_assignment_status_type_id IN OUT NOCOPY NUMBER
,p_d_status                       VARCHAR2
,p_requery_required        IN OUT NOCOPY VARCHAR2
,p_clear_details  VARCHAR2 DEFAULT 'N'
,p_legislation_code               VARCHAR2
,p_pds_information_category       VARCHAR2
,p_pds_information1               VARCHAR2
,p_pds_information2               VARCHAR2
,p_pds_information3               VARCHAR2
,p_pds_information4               VARCHAR2
,p_pds_information5               VARCHAR2
,p_pds_information6               VARCHAR2
,p_pds_information7               VARCHAR2
,p_pds_information8               VARCHAR2
,p_pds_information9               VARCHAR2
,p_pds_information10              VARCHAR2
,p_pds_information11              VARCHAR2
,p_pds_information12              VARCHAR2
,p_pds_information13              VARCHAR2
,p_pds_information14              VARCHAR2
,p_pds_information15              VARCHAR2
,p_pds_information16              VARCHAR2
,p_pds_information17              VARCHAR2
,p_pds_information18              VARCHAR2
,p_pds_information19              VARCHAR2
,p_pds_information20              VARCHAR2
,p_pds_information21              VARCHAR2
,p_pds_information22              VARCHAR2
,p_pds_information23              VARCHAR2
,p_pds_information24              VARCHAR2
,p_pds_information25              VARCHAR2
,p_pds_information26              VARCHAR2
,p_pds_information27              VARCHAR2
,p_pds_information28              VARCHAR2
,p_pds_information29              VARCHAR2
,p_pds_information30              VARCHAR2
,p_adjusted_svc_date              DATE
,p_dodwarning                 OUT NOCOPY VARCHAR2) is
--
l_proc varchar2(30) := 'update_term_row';
l_old_date_start date;
l_old_leaving_reason varchar2(30);
l_old_final_process_date date;
l_old_actual_termination_date date;
l_localization_action boolean := FALSE;
l_action varchar2(20);
--
-- Amended for Bug 1293835
cursor get_old_pds_values is
  select date_start,
         actual_termination_date,
         final_process_date,
         leaving_reason
    from per_periods_of_service
   where period_of_service_id = p_period_of_service_id;

  -- Added for Bug 1150185
  --
  cursor c1(p_date date) is
    select rowid,
           business_group_id,
           person_id,
           effective_start_date,
           effective_end_date,
           date_of_birth,
           date_of_death,
           marital_status,
           on_military_service,
           registered_disabled_flag,
           sex,
           student_status,
           coord_ben_med_pln_no,
           coord_ben_no_cvg_flag,
           uses_tobacco_flag,
           benefit_group_id,
           per_information10,
           original_date_of_hire,
           dpdnt_vlntry_svce_flag,
           receipt_of_death_cert_date,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15,
           attribute16,
           attribute17,
           attribute18,
           attribute19,
           attribute20,
           attribute21,
           attribute22,
           attribute23,
           attribute24,
           attribute25,
           attribute26,
           attribute27,
           attribute28,
           attribute29,
           attribute30
    from   per_all_people_f
    where  person_id = p_person_id
    and    p_date
           between effective_start_date
           and     effective_end_date;
  --
  l_c1 c1%rowtype;
  l_c2 c1%rowtype;
  --
  -- End Addition for Bug 1150185
  --
l_person_type_usage_id 		NUMBER(15);
l_object_version_number		NUMBER(15);
l_effective_start_date		DATE;
l_effective_end_date		DATE;

begin
  --
  -- PRE-UPDATE processing
  --
  hr_utility.set_location('Entering '||l_proc,0);
  --
  -- Get the current values for the PDS so that we can
  -- maintain the PTU information.
  --
  open get_old_pds_values;
  fetch get_old_pds_values into l_old_date_start, l_old_actual_termination_date
                               , l_old_final_process_date, l_old_leaving_reason;
  close get_old_pds_values;

  -- Checking to see if we need to only update pds
  -- i.e. no termination/rev term/ leav_reas needs to be done

  if (nvl(p_leaving_reason , hr_api.g_varchar2) = nvl(l_old_leaving_reason,hr_api.g_varchar2))
    and (nvl(p_actual_termination_date,hr_api.g_date) = nvl(l_old_actual_termination_date,hr_api.g_date))
    and (nvl(p_final_process_date,hr_api.g_date) = nvl(l_old_final_process_date,hr_api.g_date))
    and nvl(p_initiate_cancellation,'N') <> 'Y' then
    hr_utility.set_location('Localization Action - True',99);
    l_localization_action := TRUE;

  else
    hr_utility.set_location('Localization Action - False',99);
    l_localization_action := FALSE;
  end if;
  --
  -- Localization do not want this processing to take place.
  --
  if not l_localization_action THEN

  --
  -- Set the maintain PTU action based on the p_initiate_cancellation
  -- and whether the leaving reason has changed.
  --
    if p_initiate_cancellation = 'Y' then
        l_action := 'REV_TERM';
    elsif p_leaving_reason <> l_old_leaving_reason then
        l_action := 'LEAV_REAS';
    else
        l_action := 'TERM';
    end if;
    --
    -- Fix for bug 3889294 starts here.
    -- Commented out the code as it duplicate call.
    --
    /*
    if p_initiate_cancellation = 'Y' then
        hrempter.cancel_termination(p_person_id
                                  ,p_actual_termination_date
                                  ,p_clear_details);
    els
    */
    --
    -- And add following if condition.
    --
    IF  p_initiate_cancellation <> 'Y' THEN
    --
    if p_actual_termination_date is  not null THEN
        if (p_last_standard_process_date IS  null
            and p_legislation_code <> 'US') THEN
           fnd_message.set_name('PAY','HR_7576_ALL_MAN_PRO_FIELD');
           app_exception.raise_exception;
      end if;
      if p_actual_termination_date > p_last_standard_process_date then
        fnd_message.set_name('PAY','HR_6158_EMP_DATE_CHECK');
        app_exception.raise_exception;
      end if;
     if p_s_final_process_date is null then
        if p_actual_termination_date is not null then
          if p_final_process_date is null then
            if p_d_status is null then
              fnd_message.set_name('PAY','HR_6735_EMP_TERM_NO_STATUS');
              app_exception.raise_exception;
            end if;
           end if;
           -- do the ref int stuff
           if p_s_actual_termination_date IS null then
             hrempter.terminate_employee('PRE_UPDATE'
                                    ,p_business_group_id
                                    ,p_person_id
                                    ,p_c_assignment_status_type_id
                                    ,p_actual_termination_date
                                    ,p_last_standard_process_date
                                    ,p_final_process_date);
           elsif p_final_process_date is not null then
             hrempter.employee_shutdown('PRE_UPDATE'
                                     ,p_person_id
                                     ,p_final_process_date);
           end if;
        end if;
      end if;
    end if;
    --
    END IF;
  --
  end if;
  --
--
-- Fix for bug 3889294 starts here. Moved the following code
-- to procedure hrempter.cancle_termination.
--
/*
--
-- Added to support reverse termination processing for legislations
--
if p_initiate_cancellation = 'Y' then
--
  open csr_leg_code;
  fetch csr_leg_code into l_leg_code;
  --
  if csr_leg_code%found then
    --
    -- If one exists then we must check whether there exists a legislation
    -- specific Validate_Delete procedure. This should be named in the format
    -- PER_XX_TERMINATION.REVERSE
    -- If it does exist then construct an anonymous PL/SQL block to call
    -- the procedure.
    --
    l_package_name   := 'PER_'||l_leg_code||'_TERMINATION';
    l_procedure_name := 'REVERSE';
    --
        -- Close Cursor added a part of fix for bug 1858597
        --
        close csr_leg_code;
        --
    -- Check package exists
        --
    open csr_leg_pkg(l_package_name);
    fetch csr_leg_pkg into l_dummy;
        --
    if csr_leg_pkg%found then
          --
          close csr_leg_pkg;
          --
          -- Added as part of fix for bug 1858597
          --
          EXECUTE IMMEDIATE 'BEGIN '||
                                l_package_name||'.'||
                                        l_procedure_name||
          '(:P_PERIOD_OF_SERVICE_ID,'||
          ':P_ACTUAL_TERMINATION_DATE,'||
          ':P_LEAVING_REASON); END;'
                                  USING p_period_of_service_id
                                       ,p_actual_termination_date
                                       ,l_old_leaving_reason;
      --
    end if;
     --
  end if;
end if;
*/
--
-- Fix for bug 3889294 ends here.
--
  --
  -- VT #1364630 08/23/00
-- 3665620 Removed the code to clear of DFF during Reverse Termination
   per_periods_of_service_pkg.update_row(p_row_id => p_row_id
   ,p_period_of_service_id        => p_period_of_service_id
   ,p_business_group_id              => p_business_group_id
   ,p_person_id                      => p_person_id
   ,p_date_start                     => p_date_start
   ,p_termination_accepted_per_id => p_termination_accepted_per_id
   ,p_accepted_termination_date      => p_accepted_termination_date
   ,p_actual_termination_date        => p_actual_termination_date
   ,p_comments                       => p_comments
   ,p_final_process_date             => p_final_process_date
   ,p_last_standard_process_date     => p_last_standard_process_date
   ,p_leaving_reason                 => p_leaving_reason
   ,p_notified_termination_date      => p_notified_termination_date
   ,p_projected_termination_date     => p_projected_termination_date
   ,p_request_id                     => p_request_id
   ,p_program_application_id         => p_program_application_id
   ,p_program_id                     => p_program_id
   ,p_program_update_date            => p_program_update_date
   ,p_attribute_category             => p_attribute_category
   ,p_attribute1                     => p_attribute1
   ,p_attribute2                     => p_attribute2
   ,p_attribute3                     => p_attribute3
   ,p_attribute4                     => p_attribute4
   ,p_attribute5                     => p_attribute5
   ,p_attribute6                     => p_attribute6
   ,p_attribute7                     => p_attribute7
   ,p_attribute8                     => p_attribute8
   ,p_attribute9                     => p_attribute9
   ,p_attribute10                    => p_attribute10
   ,p_attribute11                    => p_attribute11
   ,p_attribute12                    => p_attribute12
   ,p_attribute13                    => p_attribute13
   ,p_attribute14                    => p_attribute14
   ,p_attribute15                    => p_attribute15
   ,p_attribute16                    => p_attribute16
   ,p_attribute17                    => p_attribute17
   ,p_attribute18                    => p_attribute18
   ,p_attribute19                    => p_attribute19
   ,p_attribute20                    => p_attribute20
   ,p_pds_information_category       => p_pds_information_category
   ,p_pds_information1               => p_pds_information1
   ,p_pds_information2               => p_pds_information2
   ,p_pds_information3               => p_pds_information3
   ,p_pds_information4               => p_pds_information4
   ,p_pds_information5               => p_pds_information5
   ,p_pds_information6               => p_pds_information6
   ,p_pds_information7               => p_pds_information7
   ,p_pds_information8               => p_pds_information8
   ,p_pds_information9               => p_pds_information9
   ,p_pds_information10              => p_pds_information10
   ,p_pds_information11              => p_pds_information11
   ,p_pds_information12              => p_pds_information12
   ,p_pds_information13              => p_pds_information13
   ,p_pds_information14              => p_pds_information14
   ,p_pds_information15              => p_pds_information15
   ,p_pds_information16              => p_pds_information16
   ,p_pds_information17              => p_pds_information17
   ,p_pds_information18              => p_pds_information18
   ,p_pds_information19              => p_pds_information19
   ,p_pds_information20              => p_pds_information20
   ,p_pds_information21              => p_pds_information21
   ,p_pds_information22              => p_pds_information22
   ,p_pds_information23              => p_pds_information23
   ,p_pds_information24              => p_pds_information24
   ,p_pds_information25              => p_pds_information25
   ,p_pds_information26              => p_pds_information26
   ,p_pds_information27              => p_pds_information27
   ,p_pds_information28              => p_pds_information28
   ,p_pds_information29              => p_pds_information29
   ,p_pds_information30              => p_pds_information30
   ,p_adjusted_svc_date              => p_adjusted_svc_date
);
  --
  -- Post Update processing
  --
  -- Localization do not want this processing to take place.
  --
  if not l_localization_action THEN

     -- fix bug 1234721
     -- parameter should remain null
     -- p_s_final_process_date := p_final_process_date;
     hr_utility.set_location('Entering: hrempter.cancel_termination'|| l_proc, 5);
     if p_initiate_cancellation ='Y' then
        hrempter.cancel_termination(p_person_id
                                   ,p_actual_termination_date
                                   ,p_clear_details);
        p_requery_required := 'Y';
       hr_utility.set_location('After: hrempter.cancel_termination'|| l_proc, 10);
     /* This code is added to raise BE on reverse termination of employee */

       hr_ex_employee_be4.reverse_terminate_employee_a(p_person_id
                                                      ,p_actual_termination_date
                                                      ,p_clear_details);
      hr_utility.set_location('After: hr_ex_employee_be4.reverse_terminate_employee_a'|| l_proc, 15);
    /* End of code added to raise BE */
     elsif p_actual_termination_date is not null then
        if p_s_actual_termination_date is null then
           -- fix bug 1234721
           -- parameter should remain null
           -- p_s_actual_termination_date := p_actual_termination_date;
       --
       --
/* This delete is now doen in hrempter.terminate_employee so that the
   deletion of pay proposals can be kept in step with the deletion
   of elements.

            per_periods_of_service_pkg.delete_per_pay_proposals(
                  p_period_of_service_id => p_period_of_service_id
                 ,p_actual_termination_date => p_actual_termination_date);
*/
            hrempter.terminate_employee('POST_UPDATE'
                                       ,p_business_group_id
                                       ,p_person_id
                                       ,p_c_assignment_status_type_id
                                       ,p_actual_termination_date
                                       ,p_last_standard_process_date
                                       ,p_final_process_date);
            p_requery_required := 'Y';
            --
         elsif p_final_process_date is not null then
            hrempter.employee_shutdown ('POST_UPDATE'
                                       ,p_person_id
                                       ,p_final_process_date);
            p_requery_required := 'Y';
         end if;
      end if;
      --
      if p_actual_termination_date is not null and
        p_leaving_reason = 'D' then
           update per_people_f
           set date_of_death = p_actual_termination_date
           where person_id = p_person_id
           and effective_start_date >= p_actual_termination_date +1
           and date_of_death is null;
           if SQL%FOUND then
             p_dodwarning := 'Y';
           end if;
           --
           -- Fixed for WWBUG 1150185.
           -- Call benefit dt handler when date of death changed
           --
           -- First get old stuff
           --
           open c1(p_actual_termination_date);
             fetch c1 into l_c1;
           close c1;
           --
           -- Now get new stuff following update above
           --
           open c1(p_actual_termination_date+1);
             fetch c1 into l_c2;
           close c1;
           --
           ben_dt_trgr_handle.person
             (p_rowid                      => l_c1.rowid
             ,p_business_group_id          => l_c2.business_group_id
             ,p_person_id                  => l_c2.person_id
             ,p_effective_start_date       => l_c2.effective_start_date
             ,p_effective_end_date         => l_c2.effective_start_date
             ,p_date_of_birth              => l_c2.date_of_birth
             ,p_date_of_death              => l_c2.date_of_death
             ,p_marital_status             => l_c2.marital_status
             ,p_on_military_service        => l_c2.on_military_service
             ,p_registered_disabled_flag   => l_c2.registered_disabled_flag
             ,p_sex                        => l_c2.sex
             ,p_student_status             => l_c2.student_status
             ,p_coord_ben_med_pln_no       => l_c2.coord_ben_med_pln_no
             ,p_coord_ben_no_cvg_flag      => l_c2.coord_ben_no_cvg_flag
             ,p_uses_tobacco_flag          => l_c2.uses_tobacco_flag
             ,p_benefit_group_id           => l_c2.benefit_group_id
             ,p_per_information10          => l_c2.per_information10
             ,p_original_date_of_hire      => l_c2.original_date_of_hire
             ,p_dpdnt_vlntry_svce_flag     => l_c2.dpdnt_vlntry_svce_flag
             ,p_receipt_of_death_cert_date => l_c2.receipt_of_death_cert_date
             ,p_attribute1                 => l_c2.attribute1
             ,p_attribute2                 => l_c2.attribute2
             ,p_attribute3                 => l_c2.attribute3
             ,p_attribute4                 => l_c2.attribute4
             ,p_attribute5                 => l_c2.attribute5
             ,p_attribute6                 => l_c2.attribute6
             ,p_attribute7                 => l_c2.attribute7
             ,p_attribute8                 => l_c2.attribute8
             ,p_attribute9                 => l_c2.attribute9
             ,p_attribute10                => l_c2.attribute10
             ,p_attribute11                => l_c2.attribute11
             ,p_attribute12                => l_c2.attribute12
             ,p_attribute13                => l_c2.attribute13
             ,p_attribute14                => l_c2.attribute14
             ,p_attribute15                => l_c2.attribute15
             ,p_attribute16                => l_c2.attribute16
             ,p_attribute17                => l_c2.attribute17
             ,p_attribute18                => l_c2.attribute18
             ,p_attribute19                => l_c2.attribute19
             ,p_attribute20                => l_c2.attribute20
             ,p_attribute21                => l_c2.attribute21
             ,p_attribute22                => l_c2.attribute22
             ,p_attribute23                => l_c2.attribute23
             ,p_attribute24                => l_c2.attribute24
             ,p_attribute25                => l_c2.attribute25
             ,p_attribute26                => l_c2.attribute26
             ,p_attribute27                => l_c2.attribute27
             ,p_attribute28                => l_c2.attribute28
             ,p_attribute29                => l_c2.attribute29
             ,p_attribute30                => l_c2.attribute30);
        --
      end if;
      --
      -- Process the maintenance of the PTU records
      -- This is required for OAB BD1/BD2 work and will
      -- be required in 11.5 of HR until the new person
      -- type model gets fully incorporated.
      --
      hr_utility.set_location(l_proc,40);
      hr_utility.set_location('Cancel? : '||p_initiate_cancellation,07);
--      hr_per_type_usage_internal.maintain_ptu(
--                   p_person_id => p_person_id,
--                   p_action => l_action,
--                   p_period_of_service_id => p_period_of_service_id,
--                   p_actual_termination_date => p_actual_termination_date,
--                   p_business_group_id => p_business_group_id,
--                   p_date_start => p_date_start,
--                   p_leaving_reason => p_leaving_reason,
--                   p_old_date_start => l_old_date_start,
--                   p_old_leaving_reason => l_old_leaving_reason);
      hr_utility.set_location('Leaving '||l_proc,60);
--
-- Fix for bug 3889294 starts here.
-- Moved the PTU changes code to procedure hrempter.cancel_termination
-- for reverse termination case.
--
/*
-- start of PTU Changes
if l_action = 'REV_TERM'
   then -- Cancel Person Type Usage record
      hr_utility.set_location('REV_TERM '||l_proc,65);
        if p_leaving_reason = 'R' then
           hr_utility.set_location('REV_TERM '||l_proc,67);
           hr_per_type_usage_internal.cancel_person_type_usage
           (p_effective_date         => p_actual_termination_date+1
           ,p_person_id              => p_person_id
           ,p_system_person_type     => 'RETIREE');
     -- end if; fix Bug 2048953
        else
           hr_utility.set_location('REV_TERM '||l_proc,68);
           hr_per_type_usage_internal.cancel_person_type_usage
           (p_effective_date         => p_actual_termination_date+1
           ,p_person_id              => p_person_id
           ,p_system_person_type     => 'EX_EMP');
        end if;
els
*/
--
-- Fix for bug 3889294 ends here.
--
if (l_action = 'TERM'
          and l_old_actual_termination_date is null
          and p_actual_termination_date is not null )  -- Bug 2189611
   then -- terminate
      hr_utility.set_location('TERM '||l_proc,70);
      hr_per_type_usage_internal.maintain_person_type_usage
      (p_effective_date         => p_actual_termination_date+1
      ,p_person_id              => p_person_id
      ,p_person_type_id         =>
                hr_person_type_usage_info.get_default_person_type_id
                        (p_business_group_id    => p_business_group_id
                        ,p_system_person_type   => 'EX_EMP')
      ,p_datetrack_update_mode  => 'UPDATE');

      if p_leaving_reason = 'R'
        then
           hr_per_type_usage_internal.create_person_type_usage
           (p_person_id            => p_person_id
           ,p_person_type_id       =>
                hr_person_type_usage_info.get_default_person_type_id
                     (p_business_group_id    => p_business_group_id
                     ,p_system_person_type   => 'RETIREE')
           ,p_effective_date       => p_actual_termination_date+1
           ,p_person_type_usage_id => l_person_type_usage_id
           ,p_object_version_number=> l_object_version_number
           ,p_effective_start_date => l_effective_start_date
           ,p_effective_end_date   => l_effective_end_date);
      end if;
elsif (l_action = 'LEAV_REAS'
       and p_actual_termination_date is not null )  -- Bug 2189611
-- then  if l_old_leaving_reason 'R' the remove Retiree record for the person
-- else  if p_leaving_reason is 'R' the create a Retiree record for the person
   then
      hr_utility.set_location('LEAV_REAS '||l_proc,75);
      if l_old_leaving_reason = 'R' then
         hr_utility.set_location('LEAV_REAS '||l_proc,80);
         hr_per_type_usage_internal.maintain_person_type_usage
         (p_effective_date         => p_actual_termination_date+1
         ,p_person_id              => p_person_id
         ,p_person_type_id         =>
                hr_person_type_usage_info.get_default_person_type_id
                      (p_business_group_id    => p_business_group_id
                      ,p_system_person_type   => 'RETIREE')
         ,p_datetrack_delete_mode  => 'ZAP');
      elsif p_leaving_reason = 'R' then
         hr_per_type_usage_internal.create_person_type_usage
         (p_person_id            => p_person_id
         ,p_person_type_id       =>
                hr_person_type_usage_info.get_default_person_type_id
                     (p_business_group_id    => p_business_group_id
                     ,p_system_person_type   => 'RETIREE')
         ,p_effective_date       => p_actual_termination_date+1
         ,p_person_type_usage_id => l_person_type_usage_id
         ,p_object_version_number=> l_object_version_number
         ,p_effective_start_date => l_effective_start_date
         ,p_effective_end_date   => l_effective_end_date);
      end if;
end if;

  --
end if;
--
end update_term_row;
------------------------------------------------------------------------------
procedure update_row(p_row_id VARCHAR2
,p_period_of_service_id           NUMBER
,p_business_group_id              NUMBER
,p_person_id                      NUMBER
,p_date_start                     DATE
,p_termination_accepted_per_id NUMBER
,p_accepted_termination_date      DATE
,p_actual_termination_date        DATE
,p_comments                       VARCHAR2
,p_final_process_date             DATE
,p_last_standard_process_date     DATE
,p_leaving_reason                 VARCHAR2
,p_notified_termination_date      DATE
,p_projected_termination_date     DATE
,p_request_id                     NUMBER
,p_program_application_id         NUMBER
,p_program_id                     NUMBER
,p_program_update_date            DATE
,p_attribute_category             VARCHAR2
,p_attribute1                     VARCHAR2
,p_attribute2                     VARCHAR2
,p_attribute3                     VARCHAR2
,p_attribute4                     VARCHAR2
,p_attribute5                     VARCHAR2
,p_attribute6                     VARCHAR2
,p_attribute7                     VARCHAR2
,p_attribute8                     VARCHAR2
,p_attribute9                     VARCHAR2
,p_attribute10                    VARCHAR2
,p_attribute11                    VARCHAR2
,p_attribute12                    VARCHAR2
,p_attribute13                    VARCHAR2
,p_attribute14                    VARCHAR2
,p_attribute15                    VARCHAR2
,p_attribute16                    VARCHAR2
,p_attribute17                    VARCHAR2
,p_attribute18                    VARCHAR2
,p_attribute19                    VARCHAR2
,p_attribute20                    VARCHAR2
,p_pds_information_category       VARCHAR2
,p_pds_information1               VARCHAR2
,p_pds_information2               VARCHAR2
,p_pds_information3               VARCHAR2
,p_pds_information4               VARCHAR2
,p_pds_information5               VARCHAR2
,p_pds_information6               VARCHAR2
,p_pds_information7               VARCHAR2
,p_pds_information8               VARCHAR2
,p_pds_information9               VARCHAR2
,p_pds_information10              VARCHAR2
,p_pds_information11              VARCHAR2
,p_pds_information12              VARCHAR2
,p_pds_information13              VARCHAR2
,p_pds_information14              VARCHAR2
,p_pds_information15              VARCHAR2
,p_pds_information16              VARCHAR2
,p_pds_information17              VARCHAR2
,p_pds_information18              VARCHAR2
,p_pds_information19              VARCHAR2
,p_pds_information20              VARCHAR2
,p_pds_information21              VARCHAR2
,p_pds_information22              VARCHAR2
,p_pds_information23              VARCHAR2
,p_pds_information24              VARCHAR2
,p_pds_information25              VARCHAR2
,p_pds_information26              VARCHAR2
,p_pds_information27              VARCHAR2
,p_pds_information28              VARCHAR2
,p_pds_information29              VARCHAR2
,p_pds_information30              VARCHAR2
,p_adjusted_svc_date              DATE
) is
  --
--
-- START WWBUG fix for 1390173
--
  cursor c1 is
    select *
    from   per_periods_of_service
    where  rowid = chartorowid(p_row_id);
  --
  l_c1 c1%rowtype;
  --
  l_old   ben_pps_ler.g_pps_ler_rec;
  l_new   ben_pps_ler.g_pps_ler_rec;
  --
--
-- END WWBUG fix for 1390173
--
begin
   --
--
-- START WWBUG fix for 1390173
--
   open c1;
     fetch c1 into l_c1;
     if c1%found then
       --
       l_old.PERSON_ID := l_c1.person_id;
       l_old.BUSINESS_GROUP_ID := l_c1.business_group_id;
       l_old.DATE_START := l_c1.date_start;
       l_old.ACTUAL_TERMINATION_DATE := l_c1.actual_termination_date;
       l_old.LEAVING_REASON := l_c1.leaving_reason;
       l_old.ADJUSTED_SVC_DATE := l_c1.adjusted_svc_date;
       l_old.ATTRIBUTE1 := l_c1.attribute1;
       l_old.ATTRIBUTE2 := l_c1.attribute2;
       l_old.ATTRIBUTE3 := l_c1.attribute3;
       l_old.ATTRIBUTE4 := l_c1.attribute4;
       l_old.ATTRIBUTE5 := l_c1.attribute5;
       l_old.final_process_date := l_c1.final_process_date;
       l_new.PERSON_ID := p_person_id;
       l_new.BUSINESS_GROUP_ID := p_business_group_id;
       l_new.DATE_START := p_date_start;
       l_new.ACTUAL_TERMINATION_DATE := p_actual_termination_date;
       l_new.LEAVING_REASON := p_leaving_reason;
       l_new.ADJUSTED_SVC_DATE := p_adjusted_svc_date;
       l_new.ATTRIBUTE1 := p_attribute1;
       l_new.ATTRIBUTE2 := p_attribute2;
       l_new.ATTRIBUTE3 := p_attribute3;
       l_new.ATTRIBUTE4 := p_attribute4;
       l_new.ATTRIBUTE5 := p_attribute5;
       l_new.final_process_date := p_final_process_date;
       --
       ben_pps_ler.ler_chk(p_old            => l_old
                          ,p_new            => l_new
                          ,p_event          => 'UPDATING'
                          ,p_effective_date => p_date_start);

       --
     end if;
   close c1;
   --
--
-- END WWBUG fix for 1390173
--
   update per_periods_of_service pps
   set pps.period_of_service_id        = p_period_of_service_id
   ,pps.business_group_id              = p_business_group_id
   ,pps.person_id                      = p_person_id
   ,pps.date_start                     = p_date_start
   ,pps.termination_accepted_person_id = p_termination_accepted_per_id
   ,pps.accepted_termination_date      = p_accepted_termination_date
   ,pps.actual_termination_date        = p_actual_termination_date
   ,pps.comments                       = p_comments
   ,pps.final_process_date             = p_final_process_date
   ,pps.last_standard_process_date     = p_last_standard_process_date
   ,pps.leaving_reason                 = p_leaving_reason
   ,pps.notified_termination_date      = p_notified_termination_date
   ,pps.projected_termination_date     = p_projected_termination_date
   ,pps.request_id                     = p_request_id
   ,pps.program_application_id         = p_program_application_id
   ,pps.program_id                     = p_program_id
   ,pps.program_update_date            = p_program_update_date
   ,pps.attribute_category             = p_attribute_category
   ,pps.attribute1                     = p_attribute1
   ,pps.attribute2                     = p_attribute2
   ,pps.attribute3                     = p_attribute3
   ,pps.attribute4                     = p_attribute4
   ,pps.attribute5                     = p_attribute5
   ,pps.attribute6                     = p_attribute6
   ,pps.attribute7                     = p_attribute7
   ,pps.attribute8                     = p_attribute8
   ,pps.attribute9                     = p_attribute9
   ,pps.attribute10                    = p_attribute10
   ,pps.attribute11                    = p_attribute11
   ,pps.attribute12                    = p_attribute12
   ,pps.attribute13                    = p_attribute13
   ,pps.attribute14                    = p_attribute14
   ,pps.attribute15                    = p_attribute15
   ,pps.attribute16                    = p_attribute16
   ,pps.attribute17                    = p_attribute17
   ,pps.attribute18                    = p_attribute18
   ,pps.attribute19                    = p_attribute19
   ,pps.attribute20                    = p_attribute20
   ,pps.pds_information_category       = p_pds_information_category
   ,pps.pds_information1               = p_pds_information1
   ,pps.pds_information2               = p_pds_information2
   ,pps.pds_information3               = p_pds_information3
   ,pps.pds_information4               = p_pds_information4
   ,pps.pds_information5               = p_pds_information5
   ,pps.pds_information6               = p_pds_information6
   ,pps.pds_information7               = p_pds_information7
   ,pps.pds_information8               = p_pds_information8
   ,pps.pds_information9               = p_pds_information9
   ,pps.pds_information10              = p_pds_information10
   ,pps.pds_information11              = p_pds_information11
   ,pps.pds_information12              = p_pds_information12
   ,pps.pds_information13              = p_pds_information13
   ,pps.pds_information14              = p_pds_information14
   ,pps.pds_information15              = p_pds_information15
   ,pps.pds_information16              = p_pds_information16
   ,pps.pds_information17              = p_pds_information17
   ,pps.pds_information18              = p_pds_information18
   ,pps.pds_information19              = p_pds_information19
   ,pps.pds_information20              = p_pds_information20
   ,pps.pds_information21              = p_pds_information21
   ,pps.pds_information22              = p_pds_information22
   ,pps.pds_information23              = p_pds_information23
   ,pps.pds_information24              = p_pds_information24
   ,pps.pds_information25              = p_pds_information25
   ,pps.pds_information26              = p_pds_information26
   ,pps.pds_information27              = p_pds_information27
   ,pps.pds_information28              = p_pds_information28
   ,pps.pds_information29              = p_pds_information29
   ,pps.pds_information30              = p_pds_information30
   ,pps.adjusted_svc_date              = p_adjusted_svc_date
   where rowid = chartorowid(p_row_id);
--

  ben_dt_trgr_handle.periods_of_service
    (p_rowid              => null
    ,p_person_id          => p_person_id
    ,p_pds_atd            => p_actual_termination_date
    ,p_pds_leaving_reason => p_leaving_reason
    ,p_pds_fpd            => p_final_process_date
    -- Bug 1854968
    ,p_pds_old_atd        => l_old.actual_termination_date
    );
--
end update_row;
----------------------------------------------------------------------------
procedure populate_status(p_person_id NUMBER
                         ,p_status in out nocopy VARCHAR2
                         ,p_assignment_status_id in out nocopy number) is
cursor st1  is SELECT  NVL(STATL.USER_STATUS,STTTL.USER_STATUS)
           ,       STT.ASSIGNMENT_STATUS_TYPE_ID
           FROM    PER_ASSIGNMENT_STATUS_TYPES_TL STTTL
           ,       PER_ASSIGNMENT_STATUS_TYPES STT
           ,       PER_ASS_STATUS_TYPE_AMENDS_TL STATL
           ,       PER_ASS_STATUS_TYPE_AMENDS STA
           ,       PER_ALL_ASSIGNMENTS_F ASG
           WHERE   ASG.PERSON_ID = p_person_id
           AND     STT.ASSIGNMENT_STATUS_TYPE_ID = STTTL.ASSIGNMENT_STATUS_TYPE_ID
           AND     STA.ASS_STATUS_TYPE_AMEND_ID =
                     STATL.ASS_STATUS_TYPE_AMEND_ID(+)
           AND     STT.ASSIGNMENT_STATUS_TYPE_ID =
                   STA.ASSIGNMENT_STATUS_TYPE_ID (+)
           AND     ASG.ASSIGNMENT_STATUS_TYPE_ID = STT.ASSIGNMENT_STATUS_TYPE_ID
           AND     NVL(STA.ACTIVE_FLAG,STT.ACTIVE_FLAG) = 'Y'
           AND     NVL(STT.DEFAULT_FLAG,STA.DEFAULT_FLAG) = 'Y'
           AND     ASG.PRIMARY_FLAG = 'Y'
           AND     NVL(STA.PER_SYSTEM_STATUS,STT.PER_SYSTEM_STATUS) =
                   'TERM_ASSIGN'
           AND     decode(STATL.ASS_STATUS_TYPE_AMEND_ID, NULL, '1', STATL.LANGUAGE)
                   = decode(STATL.ASS_STATUS_TYPE_AMEND_ID, NULL, '1', userenv('LANG'))
           AND     STTTL.LANGUAGE = USERENV('LANG');
begin
 open st1;
 fetch st1 into p_status,p_assignment_status_id;
 close st1;
end;
------------------------------------------------------------------------------
procedure form_post_query(p_session_date DATE
                         ,p_period_of_service_id NUMBER
                         ,p_business_group_id NUMBER
                         ,p_person_id NUMBER
                         ,p_tp_years IN OUT NOCOPY NUMBER
                         ,p_tp_months IN OUT NOCOPY NUMBER
                         ,p_total_years IN OUT NOCOPY NUMBER
                         ,p_total_months IN OUT NOCOPY NUMBER
                         ,p_actual_termination_date DATE
                         ,p_status IN OUT NOCOPY VARCHAR2
                         ,p_termination_accepted_id IN NUMBER
                         ,p_terminated_name IN OUT NOCOPY VARCHAR2
                         ,p_terminated_number IN OUT NOCOPY VARCHAR2
                         ,p_assignment_status_id IN OUT NOCOPY NUMBER) is
--
-- Cursor Terminated Per_id
--
cursor 	terminated_by is
select 	p.full_name,nvl(p.employee_number, p.npw_number)
from 	per_all_people_f p,
     	per_periods_of_service pps
where 	p.person_id 		= pps.termination_accepted_person_id
and   	(p.business_group_id = p_business_group_id OR
 nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N') = 'Y')
and   	pps.period_of_service_id = p_period_of_service_id
and 	nvl(pps.accepted_termination_date,p_session_date)
		between p.effective_start_date and p.effective_end_date ;
--
begin
  per_periods_of_service_pkg.get_years_months(p_session_date  => p_session_date
                        ,p_period_of_service_id => p_period_of_service_id
                        ,p_business_group_id => p_business_group_id
                        ,p_person_id => p_person_id
                        ,p_tp_years => p_tp_years
                        ,p_tp_months => p_tp_months
                        ,p_total_years => p_total_years
                        ,p_total_months => p_total_months);
   if p_actual_termination_date is not null then
      per_periods_of_service_pkg.populate_status(p_person_id => p_person_id
                        ,p_status => p_status
                        ,p_assignment_status_id => p_assignment_status_id);
   end if;
   if p_termination_accepted_id is not null then
    open terminated_by;
    fetch terminated_by into p_terminated_name, p_terminated_number;
    close terminated_by;
   end if;
end form_post_query;

END PER_PERIODS_OF_SERVICE_PKG;

/
