--------------------------------------------------------
--  DDL for Package Body PAY_MISC_DYT_INCIDENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MISC_DYT_INCIDENT_PKG" AS
/* $Header: paymiscdytincpkg.pkb 120.8 2006/12/08 14:54:12 susivasu noship $ */

/* Global definitions */
g_package varchar2(80) := 'PAY_MISC_DYT_INCIDENT_PKG';
--
---------------------------------------------------------------------------------------
-- Here are the procedures that have been built for the core triggers
---------------------------------------------------------------------------------------
--
--------------------------------------------
-- PER_PERFORMANCE_REVIEWS
--------------------------------------------
--

/* PER_PERFORMANCE_REVIEWS_ari */
/* name : PER_PERFORMANCE_REVIEWS_ari
   purpose : This is procedure that records any insert
             on performance review.
*/
PROCEDURE per_performance_reviews_ari(
                                         p_business_group_id in number,
                                         p_legislation_code in varchar2,
                                         p_person_id in number,
                                         p_performance_review_id in number,
                                         p_effective_start_date in date
                                        )
IS
  --
  cursor asgcur (p_person_id number) is
  select distinct assignment_id
    from per_all_assignments_f
   where person_id = p_person_id;
   --
  l_process_event_id      number;
  l_object_version_number number;
  l_proc varchar2(240) := g_package||'.per_performance_reviews_ari';
  --
BEGIN
  --
  hr_utility.set_location(l_proc, 10);
  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
  --
  pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     NULL,
                                     NULL,
                                     NULL,
                                     p_effective_start_date,
                                     p_effective_start_date,
                                     'I'
                                    );
  /* Now call the API for the affected assignments */
  DECLARE
    cnt number;
    l_process_event_id number;
    l_object_version_number number;
  BEGIN
    IF (pay_continuous_calc.g_event_list.sz <> 0) THEN
      --
      FOR asgrec in asgcur (p_person_id) LOOP
        --
        FOR cnt in 1..pay_continuous_calc.g_event_list.sz LOOP
          --
          pay_ppe_api.create_process_event(
             p_assignment_id         => asgrec.assignment_id,
             p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
             p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
             p_status                => 'U',
             p_description           => pay_continuous_calc.g_event_list.description(cnt),
             p_process_event_id      => l_process_event_id,
             p_object_version_number => l_object_version_number,
             p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
             p_business_group_id     => p_business_group_id,
             p_calculation_date      => pay_continuous_calc.g_event_list.calc_date(cnt),
             p_surrogate_key         => p_performance_review_id);
          --
        END LOOP;
        --
      END LOOP;
      --
    END IF;
    --
    pay_continuous_calc.g_event_list.sz := 0;
    --
  END;
  --
  hr_utility.set_location(l_proc, 900);
  --
END per_performance_reviews_ari;

/* Used generator to build this procedure, but removed the references to
date columns as this is a non-datetrack table
We are assuming always correction
*/
/* PER_PERFORMANCE_REVIEWS */
/* name : PER_PERFORMANCE_REVIEWS
   purpose : This is procedure that records any changes for updates
             on per_performance_reviews CORRECTION only.
*/
procedure PER_PERFORMANCE_REVIEWS_aru(
    p_business_group_id in number,
    p_legislation_code in varchar2,
    p_effective_date in date ,
    p_old_ATTRIBUTE1 in VARCHAR2,
    p_new_ATTRIBUTE1 in VARCHAR2 ,
    p_old_ATTRIBUTE10 in VARCHAR2,
    p_new_ATTRIBUTE10 in VARCHAR2 ,
    p_old_ATTRIBUTE11 in VARCHAR2,
    p_new_ATTRIBUTE11 in VARCHAR2 ,
    p_old_ATTRIBUTE12 in VARCHAR2,
    p_new_ATTRIBUTE12 in VARCHAR2 ,
    p_old_ATTRIBUTE13 in VARCHAR2,
    p_new_ATTRIBUTE13 in VARCHAR2 ,
    p_old_ATTRIBUTE14 in VARCHAR2,
    p_new_ATTRIBUTE14 in VARCHAR2 ,
    p_old_ATTRIBUTE15 in VARCHAR2,
    p_new_ATTRIBUTE15 in VARCHAR2 ,
    p_old_ATTRIBUTE16 in VARCHAR2,
    p_new_ATTRIBUTE16 in VARCHAR2 ,
    p_old_ATTRIBUTE17 in VARCHAR2,
    p_new_ATTRIBUTE17 in VARCHAR2 ,
    p_old_ATTRIBUTE18 in VARCHAR2,
    p_new_ATTRIBUTE18 in VARCHAR2 ,
    p_old_ATTRIBUTE19 in VARCHAR2,
    p_new_ATTRIBUTE19 in VARCHAR2 ,
    p_old_ATTRIBUTE2 in VARCHAR2,
    p_new_ATTRIBUTE2 in VARCHAR2 ,
    p_old_ATTRIBUTE20 in VARCHAR2,
    p_new_ATTRIBUTE20 in VARCHAR2 ,
    p_old_ATTRIBUTE21 in VARCHAR2,
    p_new_ATTRIBUTE21 in VARCHAR2 ,
    p_old_ATTRIBUTE22 in VARCHAR2,
    p_new_ATTRIBUTE22 in VARCHAR2 ,
    p_old_ATTRIBUTE23 in VARCHAR2,
    p_new_ATTRIBUTE23 in VARCHAR2 ,
    p_old_ATTRIBUTE24 in VARCHAR2,
    p_new_ATTRIBUTE24 in VARCHAR2,
    p_old_ATTRIBUTE25 in VARCHAR2,
    p_new_ATTRIBUTE25 in VARCHAR2 ,
    p_old_ATTRIBUTE26 in VARCHAR2,
    p_new_ATTRIBUTE26 in VARCHAR2 ,
    p_old_ATTRIBUTE27 in VARCHAR2,
    p_new_ATTRIBUTE27 in VARCHAR2 ,
    p_old_ATTRIBUTE28 in VARCHAR2,
    p_new_ATTRIBUTE28 in VARCHAR2 ,
    p_old_ATTRIBUTE29 in VARCHAR2,
    p_new_ATTRIBUTE29 in VARCHAR2 ,
    p_old_ATTRIBUTE3 in VARCHAR2,
    p_new_ATTRIBUTE3 in VARCHAR2 ,
    p_old_ATTRIBUTE30 in VARCHAR2,
    p_new_ATTRIBUTE30 in VARCHAR2 ,
    p_old_ATTRIBUTE4 in VARCHAR2,
    p_new_ATTRIBUTE4 in VARCHAR2 ,
    p_old_ATTRIBUTE5 in VARCHAR2,
    p_new_ATTRIBUTE5 in VARCHAR2 ,
    p_old_ATTRIBUTE6 in VARCHAR2,
    p_new_ATTRIBUTE6 in VARCHAR2 ,
    p_old_ATTRIBUTE7 in VARCHAR2,
    p_new_ATTRIBUTE7 in VARCHAR2 ,
    p_old_ATTRIBUTE8 in VARCHAR2,
    p_new_ATTRIBUTE8 in VARCHAR2 ,
    p_old_ATTRIBUTE9 in VARCHAR2,
    p_new_ATTRIBUTE9 in VARCHAR2 ,
    p_old_ATTRIBUTE_CATEGORY in VARCHAR2,
    p_new_ATTRIBUTE_CATEGORY in VARCHAR2 ,
    p_old_EVENT_ID in NUMBER,
    p_new_EVENT_ID in NUMBER ,
    p_old_NEXT_PERF_REVIEW_DATE in DATE,
    p_new_NEXT_PERF_REVIEW_DATE in DATE ,
    p_old_PERFORMANCE_RATING in VARCHAR2,
    p_new_PERFORMANCE_RATING in VARCHAR2 ,
    p_old_PERFORMANCE_REVIEW_ID in NUMBER,
    p_new_PERFORMANCE_REVIEW_ID in NUMBER ,
    p_old_PERSON_ID in NUMBER,
    p_new_PERSON_ID in NUMBER ,
    p_old_REVIEW_DATE in DATE,
    p_new_REVIEW_DATE in DATE
)
is
--
  cursor asgcur (p_person_id number) is
  select distinct assignment_id
    from per_all_assignments_f
   where person_id = p_person_id;

  l_proc varchar2(240) := g_package||'.per_performance_reviews_aru';
begin
  hr_utility.set_location(l_proc,10);

  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
--
  /* If the dates havent changed it must be a correction */
  -- We are assuming always a CORRECTION as non-datetracked table!
  --if (p_old_ = p_new_
     --and  p_old_ = p_new_) then
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE1',
                                     p_old_ATTRIBUTE1,
                                     p_new_ATTRIBUTE1,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE10',
                                     p_old_ATTRIBUTE10,
                                     p_new_ATTRIBUTE10,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE11',
                                     p_old_ATTRIBUTE11,
                                     p_new_ATTRIBUTE11,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE12',
                                     p_old_ATTRIBUTE12,
                                     p_new_ATTRIBUTE12,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE13',
                                     p_old_ATTRIBUTE13,
                                     p_new_ATTRIBUTE13,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE14',
                                     p_old_ATTRIBUTE14,
                                     p_new_ATTRIBUTE14,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE15',
                                     p_old_ATTRIBUTE15,
                                     p_new_ATTRIBUTE15,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE16',
                                     p_old_ATTRIBUTE16,
                                     p_new_ATTRIBUTE16,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE17',
                                     p_old_ATTRIBUTE17,
                                     p_new_ATTRIBUTE17,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE18',
                                     p_old_ATTRIBUTE18,
                                     p_new_ATTRIBUTE18,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE19',
                                     p_old_ATTRIBUTE19,
                                     p_new_ATTRIBUTE19,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE2',
                                     p_old_ATTRIBUTE2,
                                     p_new_ATTRIBUTE2,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE20',
                                     p_old_ATTRIBUTE20,
                                     p_new_ATTRIBUTE20,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE21',
                                     p_old_ATTRIBUTE21,
                                     p_new_ATTRIBUTE21,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE22',
                                     p_old_ATTRIBUTE22,
                                     p_new_ATTRIBUTE22,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE23',
                                     p_old_ATTRIBUTE23,
                                     p_new_ATTRIBUTE23,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE24',
                                     p_old_ATTRIBUTE24,
                                     p_new_ATTRIBUTE24,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE25',
                                     p_old_ATTRIBUTE25,
                                     p_new_ATTRIBUTE25,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE26',
                                     p_old_ATTRIBUTE26,
                                     p_new_ATTRIBUTE26,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE27',
                                     p_old_ATTRIBUTE27,
                                     p_new_ATTRIBUTE27,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE28',
                                     p_old_ATTRIBUTE28,
                                     p_new_ATTRIBUTE28,
                                     p_effective_date
                                  );

--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE29',
                                     p_old_ATTRIBUTE29,
                                     p_new_ATTRIBUTE29,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE3',
                                     p_old_ATTRIBUTE3,
                                     p_new_ATTRIBUTE3,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE30',
                                     p_old_ATTRIBUTE30,
                                     p_new_ATTRIBUTE30,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE4',
                                     p_old_ATTRIBUTE4,
                                     p_new_ATTRIBUTE4,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE5',
                                     p_old_ATTRIBUTE5,
                                     p_new_ATTRIBUTE5,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE6',
                                     p_old_ATTRIBUTE6,
                                     p_new_ATTRIBUTE6,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE7',
                                     p_old_ATTRIBUTE7,
                                     p_new_ATTRIBUTE7,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE8',
                                     p_old_ATTRIBUTE8,
                                     p_new_ATTRIBUTE8,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE9',
                                     p_old_ATTRIBUTE9,
                                     p_new_ATTRIBUTE9,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'ATTRIBUTE_CATEGORY',
                                     p_old_ATTRIBUTE_CATEGORY,
                                     p_new_ATTRIBUTE_CATEGORY,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'EVENT_ID',
                                     p_old_EVENT_ID,
                                     p_new_EVENT_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'NEXT_PERF_REVIEW_DATE',
                                     p_old_NEXT_PERF_REVIEW_DATE,
                                     p_new_NEXT_PERF_REVIEW_DATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'PERFORMANCE_RATING',
                                     p_old_PERFORMANCE_RATING,
                                     p_new_PERFORMANCE_RATING,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'PERFORMANCE_REVIEW_ID',
                                     p_old_PERFORMANCE_REVIEW_ID,
                                     p_new_PERFORMANCE_REVIEW_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'PERSON_ID',
                                     p_old_PERSON_ID,
                                     p_new_PERSON_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     'REVIEW_DATE',
                                     p_old_REVIEW_DATE,
                                     p_new_REVIEW_DATE,
                                     p_effective_date
                                  );

  --end if;
--
   /* Now call the API for the affected assignments */
   declare
     l_process_event_id      number;
     l_object_version_number number;
     cnt number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
      for asgrec in asgcur (p_old_person_id) loop
       for cnt in 1..pay_continuous_calc.g_event_list.sz loop
          pay_ppe_api.create_process_event(
            p_assignment_id         => asgrec.assignment_id,
            p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
            p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
            p_status                => 'U',
            p_description           => pay_continuous_calc.g_event_list.description(cnt),
            p_process_event_id      => l_process_event_id,
            p_object_version_number => l_object_version_number,
            p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
            p_business_group_id     => p_business_group_id,
            p_calculation_date      => pay_continuous_calc.g_event_list.calc_date(cnt),
            p_surrogate_key         => p_new_performance_review_id
           );
          --
        END LOOP;
        --
      END LOOP;
      --
    END IF;
    --
    pay_continuous_calc.g_event_list.sz := 0;
    --
  END;
  --
  hr_utility.set_location(l_proc, 900);
  --
end PER_PERFORMANCE_REVIEWS_aru;



/* name : per_performance_reviews_ard
   purpose : This is procedure that records any deletes
             on per_performance_reviews.
*/
  procedure per_performance_reviews_ard(
                       p_business_group_id in number,
                       p_legislation_code in varchar2,
                       p_person_id in number,
                       p_effective_start_date in date,
                       p_performance_review_id in number
                       )
  is
  --
  cursor asgcur (p_person_id number) is
  select distinct assignment_id
    from per_all_assignments_f
   where person_id = p_person_id;
   --
    l_process_event_id number;
    l_object_version_number number;
    l_proc varchar2(240) := g_package||'.per_performance_reviews_ard';
  begin
  hr_utility.set_location(l_proc, 10);
  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
--
-- Date column notional as this is a non-datetrack table
-- See pycodtrg.ldt to see which value is used as 'effective_start_date'
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERFORMANCE_REVIEWS',
                                     NULL,
                                     NULL,
                                     NULL,
                                     p_effective_start_date,
                                     p_effective_start_date,
                                     'D'
                                    );
   /* Now call the API for the affected assignments */
   declare
     cnt number;
     l_process_event_id number;
     l_object_version_number number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
       for asgrec in asgcur (p_person_id) loop
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                         p_assignment_id         => asgrec.assignment_id,
                         p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
                         p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
                         p_status                => 'U',
                         p_description           => pay_continuous_calc.g_event_list.description(cnt),
                         p_process_event_id      => l_process_event_id,
                         p_object_version_number => l_object_version_number,
                         p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
                         p_surrogate_key         => p_performance_review_id,
                         p_calculation_date      => pay_continuous_calc.g_event_list.calc_date(cnt),
                         p_business_group_id     => p_business_group_id
                         );
          --
        END LOOP;
        --
      END LOOP;
      --
    END IF;
    --
    pay_continuous_calc.g_event_list.sz := 0;
    --
  END;
  --
  hr_utility.set_location(l_proc, 900);
  --
END per_performance_reviews_ard;
--
--------------------------------------------
-- PER_PERFORMANCE_REVIEWS
--------------------------------------------
--
/* per_appraisals_ari */
/* name : per_appraisals_ari
   purpose : This is procedure that records any insert
             on performance review.
*/
  procedure per_appraisals_ari(
                                         p_business_group_id in number,
                                         p_legislation_code in varchar2,
                                         p_appraisee_person_id in number,
                                         p_appraisal_id in number,
                                         p_effective_start_date in date
                                        )
  is
  --
  cursor asgcur (p_person_id number) is
  select distinct assignment_id
    from per_all_assignments_f
   where person_id = p_person_id;
   --
  l_process_event_id      number;
  l_object_version_number number;
  l_proc varchar2(240) := g_package||'.per_appraisals_ari';

  begin
  hr_utility.set_location(l_proc, 10);
  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     NULL,
                                     NULL,
                                     NULL,
                                     p_effective_start_date,
                                     p_effective_start_date,
                                     'I'
                                    );
   /* Now call the API for the affected assignments */
   declare
     cnt number;
     l_process_event_id number;
     l_object_version_number number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
       for asgrec in asgcur (p_appraisee_person_id) loop
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
             p_assignment_id         => asgrec.assignment_id,
             p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
             p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
             p_status                => 'U',
             p_description           => pay_continuous_calc.g_event_list.description(cnt),
             p_process_event_id      => l_process_event_id,
             p_object_version_number => l_object_version_number,
             p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
             p_business_group_id     => p_business_group_id,
             p_calculation_date      => pay_continuous_calc.g_event_list.calc_date(cnt),
             p_surrogate_key         => p_appraisal_id);
          --
        END LOOP;
        --
      END LOOP;
      --
    END IF;
    --
    pay_continuous_calc.g_event_list.sz := 0;
    --
  END;
  --
  hr_utility.set_location(l_proc, 900);
  --
END per_appraisals_ari;
--
procedure PER_APPRAISALS_aru(
    p_business_group_id in number,
    p_legislation_code in varchar2,
    p_effective_date in date,
    p_old_APPRAISAL_ID in NUMBER,
    p_new_APPRAISAL_ID in NUMBER,
    p_old_APPRAISAL_PERIOD_END_DAT in DATE,
    p_new_APPRAISAL_PERIOD_END_DAT in DATE,
    p_old_APPRAISAL_PERIOD_START_D in DATE,
    p_new_APPRAISAL_PERIOD_START_D in DATE,
    p_old_APPRAISAL_TEMPLATE_ID in NUMBER,
    p_new_APPRAISAL_TEMPLATE_ID in NUMBER,
    p_old_APPRAISEE_PERSON_ID in NUMBER,
    p_new_APPRAISEE_PERSON_ID in NUMBER,
    p_old_APPRAISER_PERSON_ID in NUMBER,
    p_new_APPRAISER_PERSON_ID in NUMBER,
    p_old_ATTRIBUTE1 in VARCHAR2,
    p_new_ATTRIBUTE1 in VARCHAR2,
    p_old_ATTRIBUTE2 in VARCHAR2,
    p_new_ATTRIBUTE2 in VARCHAR2,
    p_old_ATTRIBUTE3 in VARCHAR2,
    p_new_ATTRIBUTE3 in VARCHAR2,
    p_old_ATTRIBUTE4 in VARCHAR2,
    p_new_ATTRIBUTE4 in VARCHAR2,
    p_old_ATTRIBUTE5 in VARCHAR2,
    p_new_ATTRIBUTE5 in VARCHAR2,
    p_old_ATTRIBUTE6 in VARCHAR2,
    p_new_ATTRIBUTE6 in VARCHAR2,
    p_old_ATTRIBUTE7 in VARCHAR2,
    p_new_ATTRIBUTE7 in VARCHAR2,
    p_old_ATTRIBUTE8 in VARCHAR2,
    p_new_ATTRIBUTE8 in VARCHAR2,
    p_old_ATTRIBUTE9 in VARCHAR2,
    p_new_ATTRIBUTE9 in VARCHAR2,
    p_old_ATTRIBUTE10 in VARCHAR2,
    p_new_ATTRIBUTE10 in VARCHAR2,
    p_old_ATTRIBUTE11 in VARCHAR2,
    p_new_ATTRIBUTE11 in VARCHAR2,
    p_old_ATTRIBUTE12 in VARCHAR2,
    p_new_ATTRIBUTE12 in VARCHAR2,
    p_old_ATTRIBUTE13 in VARCHAR2,
    p_new_ATTRIBUTE13 in VARCHAR2,
    p_old_ATTRIBUTE14 in VARCHAR2,
    p_new_ATTRIBUTE14 in VARCHAR2,
    p_old_ATTRIBUTE15 in VARCHAR2,
    p_new_ATTRIBUTE15 in VARCHAR2,
    p_old_ATTRIBUTE16 in VARCHAR2,
    p_new_ATTRIBUTE16 in VARCHAR2,
    p_old_ATTRIBUTE17 in VARCHAR2,
    p_new_ATTRIBUTE17 in VARCHAR2,
    p_old_ATTRIBUTE18 in VARCHAR2,
    p_new_ATTRIBUTE18 in VARCHAR2,
    p_old_ATTRIBUTE19 in VARCHAR2,
    p_new_ATTRIBUTE19 in VARCHAR2,
    p_old_ATTRIBUTE20 in VARCHAR2,
    p_new_ATTRIBUTE20 in VARCHAR2,
    p_old_ATTRIBUTE_CATEGORY in VARCHAR2,
    p_new_ATTRIBUTE_CATEGORY in VARCHAR2,
    p_old_BUSINESS_GROUP_ID in NUMBER,
    p_new_BUSINESS_GROUP_ID in NUMBER,
    p_old_COMMENTS in VARCHAR2,
    p_new_COMMENTS in VARCHAR2,
    p_old_GROUP_DATE in DATE,
    p_new_GROUP_DATE in DATE,
    p_old_GROUP_INITIATOR_ID in NUMBER,
    p_new_GROUP_INITIATOR_ID in NUMBER,
    p_old_NEXT_APPRAISAL_DATE in DATE,
    p_new_NEXT_APPRAISAL_DATE in DATE,
    p_old_OPEN in VARCHAR2,
    p_new_OPEN in VARCHAR2,
    p_old_OVERALL_PERFORMANCE_LEVE in NUMBER,
    p_new_OVERALL_PERFORMANCE_LEVE in NUMBER,
    p_old_STATUS in VARCHAR2,
    p_new_STATUS in VARCHAR2,
    p_old_TYPE in VARCHAR2,
    p_new_TYPE in VARCHAR2,
    p_old_APPRAISAL_DATE in DATE,
    p_new_APPRAISAL_DATE in DATE,
    p_new_SYSTEM_TYPE in VARCHAR2,
    p_old_SYSTEM_TYPE in VARCHAR2,
    p_new_APPRAISAL_SYSTEM_STATUS in VARCHAR2,
    p_old_APPRAISAL_SYSTEM_STATUS in VARCHAR2,
    p_new_SYSTEM_PARAMS in VARCHAR2,
    p_old_SYSTEM_PARAMS in VARCHAR2,
    p_new_APPRAISEE_ACCESS in VARCHAR2,
    p_old_APPRAISEE_ACCESS in VARCHAR2,
    p_new_MAIN_APPRAISER_ID in NUMBER,
    p_old_MAIN_APPRAISER_ID in NUMBER,
    p_new_ASSIGNMENT_ID in NUMBER,
    p_old_ASSIGNMENT_ID in NUMBER,
    p_new_ASSIGNMENT_START_DATE in DATE,
    p_old_ASSIGNMENT_START_DATE in DATE,
    p_new_ASG_BUSINESS_GROUP_ID in NUMBER,
    p_old_ASG_BUSINESS_GROUP_ID in NUMBER,
    p_new_ASG_ORGANIZATION_ID in NUMBER,
    p_old_ASG_ORGANIZATION_ID in NUMBER,
    p_new_ASSIGNMENT_JOB_ID in NUMBER,
    p_old_ASSIGNMENT_JOB_ID in NUMBER,
    p_new_ASSIGNMENT_POSITION_ID in NUMBER,
    p_old_ASSIGNMENT_POSITION_ID in NUMBER,
    p_new_ASSIGNMENT_GRADE_ID in NUMBER,
    p_old_ASSIGNMENT_GRADE_ID in NUMBER,
    p_new_PTNTL_READINESS_LEVEL in VARCHAR2,
    p_old_PTNTL_READINESS_LEVEL in VARCHAR2,
    p_new_PTNTL_SHORT_TERM_WORKOPP in VARCHAR2,
    p_old_PTNTL_SHORT_TERM_WORKOPP in VARCHAR2,
    p_new_PTNTL_LONG_TERM_WORKOPP in VARCHAR2,
    p_old_PTNTL_LONG_TERM_WORKOPP in VARCHAR2,
    p_new_POTENTIAL_DETAILS in VARCHAR2,
    p_old_POTENTIAL_DETAILS in VARCHAR2,
    p_new_EVENT_ID in NUMBER,
    p_old_EVENT_ID in NUMBER
)
is
--
  cursor asgcur (p_person_id number) is
  select distinct assignment_id
    from per_all_assignments_f
   where person_id = p_person_id;
  --
  l_proc varchar2(240) := g_package||'.per_appraisals_aru';
begin
  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
--
  /* If the dates havent changed it must be a correction */
  if (p_old_APPRAISAL_DATE = p_new_APPRAISAL_DATE
     and  p_old_APPRAISAL_DATE = p_new_APPRAISAL_DATE) then
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'APPRAISAL_ID',
                                     p_old_APPRAISAL_ID,
                                     p_new_APPRAISAL_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'APPRAISAL_PERIOD_END_DATE',
                                     p_old_APPRAISAL_PERIOD_END_DAT,
                                     p_new_APPRAISAL_PERIOD_END_DAT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'APPRAISAL_PERIOD_START_DATE',
                                     p_old_APPRAISAL_PERIOD_START_D,
                                     p_new_APPRAISAL_PERIOD_START_D,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'APPRAISAL_TEMPLATE_ID',
                                     p_old_APPRAISAL_TEMPLATE_ID,
                                     p_new_APPRAISAL_TEMPLATE_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'APPRAISEE_PERSON_ID',
                                     p_old_APPRAISEE_PERSON_ID,
                                     p_new_APPRAISEE_PERSON_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'APPRAISER_PERSON_ID',
                                     p_old_APPRAISER_PERSON_ID,
                                     p_new_APPRAISER_PERSON_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'ATTRIBUTE1',
                                     p_old_ATTRIBUTE1,
                                     p_new_ATTRIBUTE1,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'ATTRIBUTE10',
                                     p_old_ATTRIBUTE10,
                                     p_new_ATTRIBUTE10,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'ATTRIBUTE11',
                                     p_old_ATTRIBUTE11,
                                     p_new_ATTRIBUTE11,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'ATTRIBUTE12',
                                     p_old_ATTRIBUTE12,
                                     p_new_ATTRIBUTE12,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'ATTRIBUTE13',
                                     p_old_ATTRIBUTE13,
                                     p_new_ATTRIBUTE13,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'ATTRIBUTE14',
                                     p_old_ATTRIBUTE14,
                                     p_new_ATTRIBUTE14,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'ATTRIBUTE15',
                                     p_old_ATTRIBUTE15,
                                     p_new_ATTRIBUTE15,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'ATTRIBUTE16',
                                     p_old_ATTRIBUTE16,
                                     p_new_ATTRIBUTE16,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'ATTRIBUTE17',
                                     p_old_ATTRIBUTE17,
                                     p_new_ATTRIBUTE17,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'ATTRIBUTE18',
                                     p_old_ATTRIBUTE18,
                                     p_new_ATTRIBUTE18,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'ATTRIBUTE19',
                                     p_old_ATTRIBUTE19,
                                     p_new_ATTRIBUTE19,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'ATTRIBUTE2',
                                     p_old_ATTRIBUTE2,
                                     p_new_ATTRIBUTE2,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'ATTRIBUTE20',
                                     p_old_ATTRIBUTE20,
                                     p_new_ATTRIBUTE20,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'ATTRIBUTE3',
                                     p_old_ATTRIBUTE3,
                                     p_new_ATTRIBUTE3,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'ATTRIBUTE4',
                                     p_old_ATTRIBUTE4,
                                     p_new_ATTRIBUTE4,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'ATTRIBUTE5',
                                     p_old_ATTRIBUTE5,
                                     p_new_ATTRIBUTE5,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'ATTRIBUTE6',
                                     p_old_ATTRIBUTE6,
                                     p_new_ATTRIBUTE6,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'ATTRIBUTE7',
                                     p_old_ATTRIBUTE7,
                                     p_new_ATTRIBUTE7,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'ATTRIBUTE8',
                                     p_old_ATTRIBUTE8,
                                     p_new_ATTRIBUTE8,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'ATTRIBUTE9',
                                     p_old_ATTRIBUTE9,
                                     p_new_ATTRIBUTE9,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'ATTRIBUTE_CATEGORY',
                                     p_old_ATTRIBUTE_CATEGORY,
                                     p_new_ATTRIBUTE_CATEGORY,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'BUSINESS_GROUP_ID',
                                     p_old_BUSINESS_GROUP_ID,
                                     p_new_BUSINESS_GROUP_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'COMMENTS',
                                     p_old_COMMENTS,
                                     p_new_COMMENTS,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'GROUP_DATE',
                                     p_old_GROUP_DATE,
                                     p_new_GROUP_DATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'GROUP_INITIATOR_ID',
                                     p_old_GROUP_INITIATOR_ID,
                                     p_new_GROUP_INITIATOR_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'NEXT_APPRAISAL_DATE',
                                     p_old_NEXT_APPRAISAL_DATE,
                                     p_new_NEXT_APPRAISAL_DATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'OPEN',
                                     p_old_OPEN,
                                     p_new_OPEN,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'OVERALL_PERFORMANCE_LEVEL_ID',
                                     p_old_OVERALL_PERFORMANCE_LEVE,
                                     p_new_OVERALL_PERFORMANCE_LEVE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'STATUS',
                                     p_old_STATUS,
                                     p_new_STATUS,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'TYPE',
                                     p_old_TYPE,
                                     p_new_TYPE,
                                     p_effective_date
                                  );
--
-- 4054711 Added support for additional columns
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'SYSTEM_TYPE',
                                     p_new_system_type,
                                     p_old_system_type,
                                     p_effective_date
                                    );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'APPRAISAL_SYSTEM_STATUS',
                                     p_new_appraisal_system_status,
                                     p_old_appraisal_system_status,
                                     p_effective_date
                                     );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'SYSTEM_PARAMS',
                                     p_new_system_params,
                                     p_old_system_params,
                                     p_effective_date
                                    );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'APPRAISEE_ACCESS',
                                     p_new_appraisee_access,
                                     p_old_appraisee_access,
                                     p_effective_date
                                    );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'MAIN_APPRAISER_ID',
                                     p_new_main_appraiser_id,
                                     p_old_main_appraiser_id,
                                     p_effective_date
                                    );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'ASSIGNMENT_ID',
                                     p_new_assignment_id,
                                     p_old_assignment_id,
                                     p_effective_date
                                    );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'ASSIGNMENT_START_DATE',
                                     p_new_assignment_start_date,
                                     p_old_assignment_start_date,
                                     p_effective_date
                                    );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'ASSIGNMENT_BUSINESS_GROUP_ID',
                                     p_new_asg_business_group_id,
                                     p_old_asg_business_group_id,
                                     p_effective_date
                                    );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'ASSIGNMENT_ORGANIZATION_ID',
                                     p_new_asg_organization_id,
                                     p_old_asg_organization_id,
                                     p_effective_date
                                    );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'ASSIGNMENT_JOB_ID',
                                     p_new_assignment_job_id,
                                     p_old_assignment_job_id,
                                     p_effective_date
                                    );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'ASSIGNMENT_POSITION_ID',
                                     p_new_assignment_position_id,
                                     p_old_assignment_position_id,
                                     p_effective_date
                                    );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'ASSIGNMENT_GRADE_ID',
                                     p_new_assignment_grade_id,
                                     p_old_assignment_grade_id,
                                     p_effective_date
                                    );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'POTENTIAL_READINESS_LEVEL',
                                     p_new_ptntl_readiness_level,
                                     p_old_ptntl_readiness_level,
                                     p_effective_date
                                    );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'POTENTIAL_SHORT_TERM_WORKOPP',
                                     p_new_ptntl_short_term_workopp,
                                     p_old_ptntl_short_term_workopp,
                                     p_effective_date
                                    );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'POTENTIAL_LONG_TERM_WORKOPP',
                                     p_new_ptntl_long_term_workopp,
                                     p_old_ptntl_long_term_workopp,
                                     p_effective_date
                                    );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'POTENTIAL_DETAILS',
                                     p_new_potential_details,
                                     p_old_potential_details,
                                     p_effective_date
                                    );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'EVENT_ID',
                                     p_new_event_id,
                                     p_old_event_id,
                                     p_effective_date
                                    );
-- 4054711
  else
    /* OK it must be a date track change */
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     'APPRAISAL_DATE',
                                     p_old_APPRAISAL_DATE,
                                     p_new_APPRAISAL_DATE,
                                     p_new_appraisal_date,
                                     least(p_old_appraisal_date,
                                           p_new_appraisal_date)
                                  );

  end if;
--
   /* Now call the API for the affected assignments */
   declare
     l_process_event_id      number;
     l_object_version_number number;
     cnt number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
       for asgrec in asgcur (p_old_appraisee_person_id) loop
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
             p_assignment_id         => asgrec.assignment_id,
             p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
             p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
             p_status                => 'U',
             p_description           => pay_continuous_calc.g_event_list.description(cnt),
             p_process_event_id      => l_process_event_id,
             p_object_version_number => l_object_version_number,
             p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
             p_business_group_id     => p_business_group_id,
             p_calculation_date      => pay_continuous_calc.g_event_list.calc_date(cnt),
             p_surrogate_key         => p_new_appraisal_id
           );
          --
        END LOOP;
        --
      END LOOP;
      --
    END IF;
    --
    pay_continuous_calc.g_event_list.sz := 0;
    --
  END;
  --
  hr_utility.set_location(l_proc, 900);
--
end PER_APPRAISALS_aru;
--
/* name : per_appraisals_ard
   purpose : This is procedure that records any deletes
             on per_appraisals.
*/
  procedure per_appraisals_ard(
                       p_business_group_id in number,
                       p_legislation_code in varchar2,
                       p_appraisee_person_id in number,
                       p_effective_start_date in date,
                       p_appraisal_id in number
                       )
  is
  --
  cursor asgcur (p_person_id number) is
  select distinct assignment_id
    from per_all_assignments_f
   where person_id = p_person_id;
   --
    l_process_event_id number;
    l_object_version_number number;
    l_proc varchar2(240) := g_package||'.per_appraisals_ard';
  begin
  hr_utility.set_location(l_proc, 10);
  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
--
-- Date column notional as this is a non-datetrack table
-- See pycodtrg.ldt to see which value is used as 'effective_start_date'
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_APPRAISALS',
                                     NULL,
                                     NULL,
                                     NULL,
                                     p_effective_start_date,
                                     p_effective_start_date,
                                     'D'
                                    );
   /* Now call the API for the affected assignments */
   declare
     cnt number;
     l_process_event_id number;
     l_object_version_number number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
       for asgrec in asgcur (p_appraisee_person_id) loop
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                         p_assignment_id         => asgrec.assignment_id,
                         p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
                         p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
                         p_status                => 'U',
                         p_description           => pay_continuous_calc.g_event_list.description(cnt),
                         p_process_event_id      => l_process_event_id,
                         p_object_version_number => l_object_version_number,
                         p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
                         p_surrogate_key         => p_appraisal_id,
                         p_calculation_date      => pay_continuous_calc.g_event_list.calc_date(cnt),
                         p_business_group_id     => p_business_group_id
                         );
          --
        END LOOP;
        --
      END LOOP;
      --
    END IF;
    --
    pay_continuous_calc.g_event_list.sz := 0;
    --
  END;
  --
  hr_utility.set_location(l_proc, 900);
  --
END per_appraisals_ard;
--
--
--------------------------------------------
-- PER_PERSON_TYPE_USAGES_F
--------------------------------------------
--

/* PER_PERSON_TYPE_USAGES_F_ari */
/* name : PER_PERSON_TYPE_USAGES_F_ari
   purpose : This is procedure that records any insert
             on performance review.
*/
PROCEDURE per_person_type_usages_f_ari(  p_business_group_id    in number,
                                         p_legislation_code     in varchar2,
                                         p_person_id            in number,
                                         p_person_type_usage_id in number,
                                         p_effective_start_date in date
                                        )
IS
  --
  cursor asgcur (p_person_id number) is
  select distinct assignment_id
    from per_all_assignments_f
   where person_id = p_person_id;
   --
  l_process_event_id      number;
  l_object_version_number number;
  l_proc varchar2(240) := g_package||'.per_person_type_usages_f_ari';
  --
BEGIN
  --
  hr_utility.set_location(l_proc, 10);
  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
  --
  pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERSON_TYPE_USAGES_F',
                                     NULL,
                                     NULL,
                                     NULL,
                                     p_effective_start_date,
                                     p_effective_start_date,
                                     'I'
                                    );
  /* Now call the API for the affected assignments */
  DECLARE
    cnt number;
    l_process_event_id number;
    l_object_version_number number;
  BEGIN
    IF (pay_continuous_calc.g_event_list.sz <> 0) THEN
      --
      FOR asgrec in asgcur (p_person_id) LOOP
        --
        FOR cnt in 1..pay_continuous_calc.g_event_list.sz LOOP
          --
          pay_ppe_api.create_process_event(
             p_assignment_id         => asgrec.assignment_id,
             p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
             p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
             p_status                => 'U',
             p_description           => pay_continuous_calc.g_event_list.description(cnt),
             p_process_event_id      => l_process_event_id,
             p_object_version_number => l_object_version_number,
             p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
             p_business_group_id     => p_business_group_id,
             p_calculation_date      => pay_continuous_calc.g_event_list.calc_date(cnt),
             p_surrogate_key         => p_person_type_usage_id);
          --
        END LOOP;
        --
      END LOOP;
      --
    END IF;
    --
    pay_continuous_calc.g_event_list.sz := 0;
    --
  END;
  --
  hr_utility.set_location(l_proc, 900);
  --
END per_person_type_usages_f_ari;

/* Used generator to build this procedure, */
/* PER_PERSON_TYPE_USAGES_F */
/* name : PER_PERSON_TYPE_USAGES_F
   purpose : This is procedure that records any changes for updates
             on PER_PERSON_TYPE_USAGES_F CORRECTION only.
*/

procedure PER_PERSON_TYPE_USAGES_F_aru(
    p_business_group_id in number,
    p_legislation_code in varchar2,
    p_effective_date in date,
    p_old_ATTRIBUTE1 in VARCHAR2,
    p_new_ATTRIBUTE1 in VARCHAR2,
    p_old_ATTRIBUTE2 in VARCHAR2,
    p_new_ATTRIBUTE2 in VARCHAR2,
    p_old_ATTRIBUTE3 in VARCHAR2,
    p_new_ATTRIBUTE3 in VARCHAR2,
    p_old_ATTRIBUTE4 in VARCHAR2,
    p_new_ATTRIBUTE4 in VARCHAR2,
    p_old_ATTRIBUTE5 in VARCHAR2,
    p_new_ATTRIBUTE5 in VARCHAR2,
    p_old_ATTRIBUTE6 in VARCHAR2,
    p_new_ATTRIBUTE6 in VARCHAR2,
    p_old_ATTRIBUTE7 in VARCHAR2,
    p_new_ATTRIBUTE7 in VARCHAR2,
    p_old_ATTRIBUTE8 in VARCHAR2,
    p_new_ATTRIBUTE8 in VARCHAR2,
    p_old_ATTRIBUTE9 in VARCHAR2,
    p_new_ATTRIBUTE9 in VARCHAR2,
    p_old_ATTRIBUTE10 in VARCHAR2,
    p_new_ATTRIBUTE10 in VARCHAR2,
    p_old_ATTRIBUTE11 in VARCHAR2,
    p_new_ATTRIBUTE11 in VARCHAR2,
    p_old_ATTRIBUTE12 in VARCHAR2,
    p_new_ATTRIBUTE12 in VARCHAR2,
    p_old_ATTRIBUTE13 in VARCHAR2,
    p_new_ATTRIBUTE13 in VARCHAR2,
    p_old_ATTRIBUTE14 in VARCHAR2,
    p_new_ATTRIBUTE14 in VARCHAR2,
    p_old_ATTRIBUTE15 in VARCHAR2,
    p_new_ATTRIBUTE15 in VARCHAR2,
    p_old_ATTRIBUTE16 in VARCHAR2,
    p_new_ATTRIBUTE16 in VARCHAR2,
    p_old_ATTRIBUTE17 in VARCHAR2,
    p_new_ATTRIBUTE17 in VARCHAR2,
    p_old_ATTRIBUTE18 in VARCHAR2,
    p_new_ATTRIBUTE18 in VARCHAR2,
    p_old_ATTRIBUTE19 in VARCHAR2,
    p_new_ATTRIBUTE19 in VARCHAR2,
    p_old_ATTRIBUTE20 in VARCHAR2,
    p_new_ATTRIBUTE20 in VARCHAR2,
    p_old_ATTRIBUTE_CATEGORY in VARCHAR2,
    p_new_ATTRIBUTE_CATEGORY in VARCHAR2,
    p_old_PERSON_ID in NUMBER,
    p_new_PERSON_ID in NUMBER,
    p_old_PERSON_TYPE_ID in NUMBER,
    p_new_PERSON_TYPE_ID in NUMBER,
    p_old_PERSON_TYPE_USAGE_ID in NUMBER,
    p_new_PERSON_TYPE_USAGE_ID in NUMBER,
    p_old_PROGRAM_APPLICATION_ID in NUMBER,
    p_new_PROGRAM_APPLICATION_ID in NUMBER,
    p_old_PROGRAM_ID in NUMBER,
    p_new_PROGRAM_ID in NUMBER,
    p_old_PROGRAM_UPDATE_DATE in DATE,
    p_new_PROGRAM_UPDATE_DATE in DATE,
    p_old_REQUEST_ID in NUMBER,
    p_new_REQUEST_ID in NUMBER,
    p_old_EFFECTIVE_END_DATE in DATE,
    p_new_EFFECTIVE_END_DATE in DATE,
    p_old_EFFECTIVE_START_DATE in DATE,
    p_new_EFFECTIVE_START_DATE in DATE
)
is
  --
  cursor asgcur (p_person_id number) is
  select distinct assignment_id
    from per_all_assignments_f
   where person_id = p_person_id;
   --
   l_proc varchar2(240) := g_package||'.per_person_type_usages_f_aru';
   --
begin
  --
  hr_utility.set_location(l_proc,10);
  --
  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
--
  /* If the dates havent changed it must be a correction */
  if (p_old_effective_end_date = p_new_effective_end_date
     and  p_old_effective_start_date = p_new_effective_start_date) then
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERSON_TYPE_USAGES_F',
                                     'ATTRIBUTE1',
                                     p_old_ATTRIBUTE1,
                                     p_new_ATTRIBUTE1,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERSON_TYPE_USAGES_F',
                                     'ATTRIBUTE10',
                                     p_old_ATTRIBUTE10,
                                     p_new_ATTRIBUTE10,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERSON_TYPE_USAGES_F',
                                     'ATTRIBUTE11',
                                     p_old_ATTRIBUTE11,
                                     p_new_ATTRIBUTE11,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERSON_TYPE_USAGES_F',
                                     'ATTRIBUTE12',
                                     p_old_ATTRIBUTE12,
                                     p_new_ATTRIBUTE12,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERSON_TYPE_USAGES_F',
                                     'ATTRIBUTE13',
                                     p_old_ATTRIBUTE13,
                                     p_new_ATTRIBUTE13,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERSON_TYPE_USAGES_F',
                                     'ATTRIBUTE14',
                                     p_old_ATTRIBUTE14,
                                     p_new_ATTRIBUTE14,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERSON_TYPE_USAGES_F',
                                     'ATTRIBUTE15',
                                     p_old_ATTRIBUTE15,
                                     p_new_ATTRIBUTE15,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERSON_TYPE_USAGES_F',
                                     'ATTRIBUTE16',
                                     p_old_ATTRIBUTE16,
                                     p_new_ATTRIBUTE16,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERSON_TYPE_USAGES_F',
                                     'ATTRIBUTE17',
                                     p_old_ATTRIBUTE17,
                                     p_new_ATTRIBUTE17,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERSON_TYPE_USAGES_F',
                                     'ATTRIBUTE18',
                                     p_old_ATTRIBUTE18,
                                     p_new_ATTRIBUTE18,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERSON_TYPE_USAGES_F',
                                     'ATTRIBUTE19',
                                     p_old_ATTRIBUTE19,
                                     p_new_ATTRIBUTE19,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERSON_TYPE_USAGES_F',
                                     'ATTRIBUTE2',
                                     p_old_ATTRIBUTE2,
                                     p_new_ATTRIBUTE2,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERSON_TYPE_USAGES_F',
                                     'ATTRIBUTE20',
                                     p_old_ATTRIBUTE20,
                                     p_new_ATTRIBUTE20,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERSON_TYPE_USAGES_F',
                                     'ATTRIBUTE3',
                                     p_old_ATTRIBUTE3,
                                     p_new_ATTRIBUTE3,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERSON_TYPE_USAGES_F',
                                     'ATTRIBUTE4',
                                     p_old_ATTRIBUTE4,
                                     p_new_ATTRIBUTE4,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERSON_TYPE_USAGES_F',
                                     'ATTRIBUTE5',
                                     p_old_ATTRIBUTE5,
                                     p_new_ATTRIBUTE5,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERSON_TYPE_USAGES_F',
                                     'ATTRIBUTE6',
                                     p_old_ATTRIBUTE6,
                                     p_new_ATTRIBUTE6,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERSON_TYPE_USAGES_F',
                                     'ATTRIBUTE7',
                                     p_old_ATTRIBUTE7,
                                     p_new_ATTRIBUTE7,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERSON_TYPE_USAGES_F',
                                     'ATTRIBUTE8',
                                     p_old_ATTRIBUTE8,
                                     p_new_ATTRIBUTE8,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERSON_TYPE_USAGES_F',
                                     'ATTRIBUTE9',
                                     p_old_ATTRIBUTE9,
                                     p_new_ATTRIBUTE9,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERSON_TYPE_USAGES_F',
                                     'ATTRIBUTE_CATEGORY',
                                     p_old_ATTRIBUTE_CATEGORY,
                                     p_new_ATTRIBUTE_CATEGORY,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERSON_TYPE_USAGES_F',
                                     'PERSON_ID',
                                     p_old_PERSON_ID,
                                     p_new_PERSON_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERSON_TYPE_USAGES_F',
                                     'PERSON_TYPE_ID',
                                     p_old_PERSON_TYPE_ID,
                                     p_new_PERSON_TYPE_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERSON_TYPE_USAGES_F',
                                     'PERSON_TYPE_USAGE_ID',
                                     p_old_PERSON_TYPE_USAGE_ID,
                                     p_new_PERSON_TYPE_USAGE_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERSON_TYPE_USAGES_F',
                                     'PROGRAM_APPLICATION_ID',
                                     p_old_PROGRAM_APPLICATION_ID,
                                     p_new_PROGRAM_APPLICATION_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERSON_TYPE_USAGES_F',
                                     'PROGRAM_ID',
                                     p_old_PROGRAM_ID,
                                     p_new_PROGRAM_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERSON_TYPE_USAGES_F',
                                     'PROGRAM_UPDATE_DATE',
                                     p_old_PROGRAM_UPDATE_DATE,
                                     p_new_PROGRAM_UPDATE_DATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERSON_TYPE_USAGES_F',
                                     'REQUEST_ID',
                                     p_old_REQUEST_ID,
                                     p_new_REQUEST_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERSON_TYPE_USAGES_F',
                                     'REQUEST_ID',
                                     p_old_REQUEST_ID,
                                     p_new_REQUEST_ID,
                                     p_effective_date
                                  );
  else
    /* OK it must be a date track change */
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERSON_TYPE_USAGES_F',
                                     'EFFECTIVE_END_DATE',
                                     p_old_EFFECTIVE_END_DATE,
                                     p_new_EFFECTIVE_END_DATE,
                                     p_new_effective_end_date,
                                     least(p_old_effective_end_date,
                                           p_new_effective_end_date)
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERSON_TYPE_USAGES_F',
                                     'EFFECTIVE_START_DATE',
                                     p_old_EFFECTIVE_START_DATE,
                                     p_new_EFFECTIVE_START_DATE,
                                     p_new_effective_start_date,
                                     least(p_old_effective_start_date,
                                           p_new_effective_start_date)
                                  );

  end if;
--
   /* Now call the API for the affected assignments */
   declare
     l_process_event_id      number;
     l_object_version_number number;
     cnt number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
       for asgrec in asgcur (p_old_person_id) loop
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
             p_assignment_id         => asgrec.assignment_id,
             p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
             p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
             p_status                => 'U',
             p_description           => pay_continuous_calc.g_event_list.description(cnt),
             p_process_event_id      => l_process_event_id,
             p_object_version_number => l_object_version_number,
             p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
             p_business_group_id     => p_business_group_id,
             p_calculation_date      => pay_continuous_calc.g_event_list.calc_date(cnt),
             p_surrogate_key         => p_new_person_type_usage_id
           );
         end loop;
       end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
  --
  hr_utility.set_location(l_proc, 900);
  --
end per_person_type_usages_f_aru;

/* name : per_person_type_usages_f_ard
   purpose : This is procedure that records any deletes
             on per_person_type_usages_f.
*/
  procedure per_person_type_usages_f_ard(
                       p_business_group_id in number,
                       p_legislation_code in varchar2,
                       p_person_id in number,
                       p_effective_start_date in date,
                       p_person_type_usage_id in number
                       )
  is
  --
  cursor asgcur (p_person_id number) is
  select distinct assignment_id
    from per_all_assignments_f
   where person_id = p_person_id;
   --
    l_process_event_id number;
    l_object_version_number number;
    l_proc varchar2(240) := g_package||'.per_person_type_usages_f_ard';
  begin
  hr_utility.set_location(l_proc, 10);
  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
--
-- Date column notional as this is a non-datetrack table
-- See pycodtrg.ldt to see which value is used as 'effective_start_date'
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERSON_TYPE_USAGES_F',
                                     NULL,
                                     NULL,
                                     NULL,
                                     p_effective_start_date,
                                     p_effective_start_date,
                                     'D'
                                    );
   /* Now call the API for the affected assignments */
   declare
     cnt number;
     l_process_event_id number;
     l_object_version_number number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
       for asgrec in asgcur (p_person_id) loop
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                         p_assignment_id         => asgrec.assignment_id,
                         p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
                         p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
                         p_status                => 'U',
                         p_description           => pay_continuous_calc.g_event_list.description(cnt),
                         p_process_event_id      => l_process_event_id,
                         p_object_version_number => l_object_version_number,
                         p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
                         p_surrogate_key         => p_person_type_usage_id,
                         p_calculation_date      => pay_continuous_calc.g_event_list.calc_date(cnt),
                         p_business_group_id     => p_business_group_id
                         );
          --
        END LOOP;
        --
      END LOOP;
      --
    END IF;
    --
    pay_continuous_calc.g_event_list.sz := 0;
    --
  END;
  --
  hr_utility.set_location(l_proc, 900);
  --
END per_person_type_usages_f_ard;
--
--------------------------------------------
-- PER_ASSIGNMENT_EXTRA_INFO
--------------------------------------------
/* Used generator to build this procedure, but removed the references to
date columns as this is a non-datetrack table
We are assuming always correction
*/
/* PER_ASSIGNMENT_EXTRA_INFO */
/* name : PER_ASSIGNMENT_EXTRA_INFO
   purpose : This is procedure that records any changes for updates
             on per_performance_reviews CORRECTION only.
*/
procedure PER_ASSIGNMENT_EXTRA_INFO_aru(
    p_business_group_id in number,
    p_legislation_code in varchar2,
    p_effective_date in date ,
    p_old_AEI_ATTRIBUTE1 in VARCHAR2,
    p_new_AEI_ATTRIBUTE1 in VARCHAR2 ,
    p_old_AEI_ATTRIBUTE10 in VARCHAR2,
    p_new_AEI_ATTRIBUTE10 in VARCHAR2 ,
    p_old_AEI_ATTRIBUTE11 in VARCHAR2,
    p_new_AEI_ATTRIBUTE11 in VARCHAR2 ,
    p_old_AEI_ATTRIBUTE12 in VARCHAR2,
    p_new_AEI_ATTRIBUTE12 in VARCHAR2 ,
    p_old_AEI_ATTRIBUTE13 in VARCHAR2,
    p_new_AEI_ATTRIBUTE13 in VARCHAR2 ,
    p_old_AEI_ATTRIBUTE14 in VARCHAR2,
    p_new_AEI_ATTRIBUTE14 in VARCHAR2 ,
    p_old_AEI_ATTRIBUTE15 in VARCHAR2,
    p_new_AEI_ATTRIBUTE15 in VARCHAR2 ,
    p_old_AEI_ATTRIBUTE16 in VARCHAR2,
    p_new_AEI_ATTRIBUTE16 in VARCHAR2 ,
    p_old_AEI_ATTRIBUTE17 in VARCHAR2,
    p_new_AEI_ATTRIBUTE17 in VARCHAR2 ,
    p_old_AEI_ATTRIBUTE18 in VARCHAR2,
    p_new_AEI_ATTRIBUTE18 in VARCHAR2 ,
    p_old_AEI_ATTRIBUTE19 in VARCHAR2,
    p_new_AEI_ATTRIBUTE19 in VARCHAR2 ,
    p_old_AEI_ATTRIBUTE2 in VARCHAR2,
    p_new_AEI_ATTRIBUTE2 in VARCHAR2 ,
    p_old_AEI_ATTRIBUTE20 in VARCHAR2,
    p_new_AEI_ATTRIBUTE20 in VARCHAR2 ,
    p_old_AEI_ATTRIBUTE3 in VARCHAR2,
    p_new_AEI_ATTRIBUTE3 in VARCHAR2 ,
    p_old_AEI_ATTRIBUTE4 in VARCHAR2,
    p_new_AEI_ATTRIBUTE4 in VARCHAR2 ,
    p_old_AEI_ATTRIBUTE5 in VARCHAR2,
    p_new_AEI_ATTRIBUTE5 in VARCHAR2 ,
    p_old_AEI_ATTRIBUTE6 in VARCHAR2,
    p_new_AEI_ATTRIBUTE6 in VARCHAR2 ,
    p_old_AEI_ATTRIBUTE7 in VARCHAR2,
    p_new_AEI_ATTRIBUTE7 in VARCHAR2 ,
    p_old_AEI_ATTRIBUTE8 in VARCHAR2,
    p_new_AEI_ATTRIBUTE8 in VARCHAR2 ,
    p_old_AEI_ATTRIBUTE9 in VARCHAR2,
    p_new_AEI_ATTRIBUTE9 in VARCHAR2 ,
    p_old_AEI_ATTRIBUTE_CATEGORY in VARCHAR2,
    p_new_AEI_ATTRIBUTE_CATEGORY in VARCHAR2 ,
    p_old_AEI_INFORMATION1 in VARCHAR2,
    p_new_AEI_INFORMATION1 in VARCHAR2 ,
    p_old_AEI_INFORMATION10 in VARCHAR2,
    p_new_AEI_INFORMATION10 in VARCHAR2 ,
    p_old_AEI_INFORMATION11 in VARCHAR2,
    p_new_AEI_INFORMATION11 in VARCHAR2 ,
    p_old_AEI_INFORMATION12 in VARCHAR2,
    p_new_AEI_INFORMATION12 in VARCHAR2 ,
    p_old_AEI_INFORMATION13 in VARCHAR2,
    p_new_AEI_INFORMATION13 in VARCHAR2 ,
    p_old_AEI_INFORMATION14 in VARCHAR2,
    p_new_AEI_INFORMATION14 in VARCHAR2 ,
    p_old_AEI_INFORMATION15 in VARCHAR2,
    p_new_AEI_INFORMATION15 in VARCHAR2 ,
    p_old_AEI_INFORMATION16 in VARCHAR2,
    p_new_AEI_INFORMATION16 in VARCHAR2 ,
    p_old_AEI_INFORMATION17 in VARCHAR2,
    p_new_AEI_INFORMATION17 in VARCHAR2 ,
    p_old_AEI_INFORMATION18 in VARCHAR2,
    p_new_AEI_INFORMATION18 in VARCHAR2 ,
    p_old_AEI_INFORMATION19 in VARCHAR2,
    p_new_AEI_INFORMATION19 in VARCHAR2 ,
    p_old_AEI_INFORMATION2 in VARCHAR2,
    p_new_AEI_INFORMATION2 in VARCHAR2 ,
    p_old_AEI_INFORMATION20 in VARCHAR2,
    p_new_AEI_INFORMATION20 in VARCHAR2 ,
    p_old_AEI_INFORMATION21 in VARCHAR2,
    p_new_AEI_INFORMATION21 in VARCHAR2 ,
    p_old_AEI_INFORMATION22 in VARCHAR2,
    p_new_AEI_INFORMATION22 in VARCHAR2 ,
    p_old_AEI_INFORMATION23 in VARCHAR2,
    p_new_AEI_INFORMATION23 in VARCHAR2 ,
    p_old_AEI_INFORMATION24 in VARCHAR2,
    p_new_AEI_INFORMATION24 in VARCHAR2 ,
    p_old_AEI_INFORMATION25 in VARCHAR2,
    p_new_AEI_INFORMATION25 in VARCHAR2 ,
    p_old_AEI_INFORMATION26 in VARCHAR2,
    p_new_AEI_INFORMATION26 in VARCHAR2 ,
    p_old_AEI_INFORMATION27 in VARCHAR2,
    p_new_AEI_INFORMATION27 in VARCHAR2 ,
    p_old_AEI_INFORMATION28 in VARCHAR2,
    p_new_AEI_INFORMATION28 in VARCHAR2 ,
    p_old_AEI_INFORMATION29 in VARCHAR2,
    p_new_AEI_INFORMATION29 in VARCHAR2 ,
    p_old_AEI_INFORMATION3 in VARCHAR2,
    p_new_AEI_INFORMATION3 in VARCHAR2 ,
    p_old_AEI_INFORMATION30 in VARCHAR2,
    p_new_AEI_INFORMATION30 in VARCHAR2 ,
    p_old_AEI_INFORMATION4 in VARCHAR2,
    p_new_AEI_INFORMATION4 in VARCHAR2 ,
    p_old_AEI_INFORMATION5 in VARCHAR2,
    p_new_AEI_INFORMATION5 in VARCHAR2 ,
    p_old_AEI_INFORMATION6 in VARCHAR2,
    p_new_AEI_INFORMATION6 in VARCHAR2 ,
    p_old_AEI_INFORMATION7 in VARCHAR2,
    p_new_AEI_INFORMATION7 in VARCHAR2 ,
    p_old_AEI_INFORMATION8 in VARCHAR2,
    p_new_AEI_INFORMATION8 in VARCHAR2 ,
    p_old_AEI_INFORMATION9 in VARCHAR2,
    p_new_AEI_INFORMATION9 in VARCHAR2 ,
    p_old_AEI_INFORMATION_CATEGORY in VARCHAR2,
    p_new_AEI_INFORMATION_CATEGORY in VARCHAR2 ,
    p_old_ASSIGNMENT_EXTRA_INFO_ID in NUMBER,
    p_new_ASSIGNMENT_EXTRA_INFO_ID in NUMBER ,
    p_old_ASSIGNMENT_ID in NUMBER,
    p_new_ASSIGNMENT_ID in NUMBER ,
    p_old_INFORMATION_TYPE in VARCHAR2,
    p_new_INFORMATION_TYPE in VARCHAR2
)
is
--
begin
  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
--
  /* If the dates havent changed it must be a correction */
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_ATTRIBUTE1',
                                     p_old_AEI_ATTRIBUTE1,
                                     p_new_AEI_ATTRIBUTE1,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_ATTRIBUTE10',
                                     p_old_AEI_ATTRIBUTE10,
                                     p_new_AEI_ATTRIBUTE10,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_ATTRIBUTE11',
                                     p_old_AEI_ATTRIBUTE11,
                                     p_new_AEI_ATTRIBUTE11,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_ATTRIBUTE12',
                                     p_old_AEI_ATTRIBUTE12,
                                     p_new_AEI_ATTRIBUTE12,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_ATTRIBUTE13',
                                     p_old_AEI_ATTRIBUTE13,
                                     p_new_AEI_ATTRIBUTE13,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_ATTRIBUTE14',
                                     p_old_AEI_ATTRIBUTE14,
                                     p_new_AEI_ATTRIBUTE14,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_ATTRIBUTE15',
                                     p_old_AEI_ATTRIBUTE15,
                                     p_new_AEI_ATTRIBUTE15,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_ATTRIBUTE16',
                                     p_old_AEI_ATTRIBUTE16,
                                     p_new_AEI_ATTRIBUTE16,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_ATTRIBUTE17',
                                     p_old_AEI_ATTRIBUTE17,
                                     p_new_AEI_ATTRIBUTE17,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_ATTRIBUTE18',
                                     p_old_AEI_ATTRIBUTE18,
                                     p_new_AEI_ATTRIBUTE18,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_ATTRIBUTE19',
                                     p_old_AEI_ATTRIBUTE19,
                                     p_new_AEI_ATTRIBUTE19,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_ATTRIBUTE2',
                                     p_old_AEI_ATTRIBUTE2,
                                     p_new_AEI_ATTRIBUTE2,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_ATTRIBUTE20',
                                     p_old_AEI_ATTRIBUTE20,
                                     p_new_AEI_ATTRIBUTE20,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_ATTRIBUTE3',
                                     p_old_AEI_ATTRIBUTE3,
                                     p_new_AEI_ATTRIBUTE3,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_ATTRIBUTE4',
                                     p_old_AEI_ATTRIBUTE4,
                                     p_new_AEI_ATTRIBUTE4,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_ATTRIBUTE5',
                                     p_old_AEI_ATTRIBUTE5,
                                     p_new_AEI_ATTRIBUTE5,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_ATTRIBUTE6',
                                     p_old_AEI_ATTRIBUTE6,
                                     p_new_AEI_ATTRIBUTE6,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_ATTRIBUTE7',
                                     p_old_AEI_ATTRIBUTE7,
                                     p_new_AEI_ATTRIBUTE7,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_ATTRIBUTE8',
                                     p_old_AEI_ATTRIBUTE8,
                                     p_new_AEI_ATTRIBUTE8,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_ATTRIBUTE9',
                                     p_old_AEI_ATTRIBUTE9,
                                     p_new_AEI_ATTRIBUTE9,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_ATTRIBUTE_CATEGORY',
                                     p_old_AEI_ATTRIBUTE_CATEGORY,
                                     p_new_AEI_ATTRIBUTE_CATEGORY,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_INFORMATION1',
                                     p_old_AEI_INFORMATION1,
                                     p_new_AEI_INFORMATION1,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_INFORMATION10',
                                     p_old_AEI_INFORMATION10,
                                     p_new_AEI_INFORMATION10,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_INFORMATION11',
                                     p_old_AEI_INFORMATION11,
                                     p_new_AEI_INFORMATION11,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_INFORMATION12',
                                     p_old_AEI_INFORMATION12,
                                     p_new_AEI_INFORMATION12,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_INFORMATION13',
                                     p_old_AEI_INFORMATION13,
                                     p_new_AEI_INFORMATION13,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_INFORMATION14',
                                     p_old_AEI_INFORMATION14,
                                     p_new_AEI_INFORMATION14,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_INFORMATION15',
                                     p_old_AEI_INFORMATION15,
                                     p_new_AEI_INFORMATION15,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_INFORMATION16',
                                     p_old_AEI_INFORMATION16,
                                     p_new_AEI_INFORMATION16,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_INFORMATION17',
                                     p_old_AEI_INFORMATION17,
                                     p_new_AEI_INFORMATION17,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_INFORMATION18',
                                     p_old_AEI_INFORMATION18,
                                     p_new_AEI_INFORMATION18,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_INFORMATION19',
                                     p_old_AEI_INFORMATION19,
                                     p_new_AEI_INFORMATION19,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_INFORMATION2',
                                     p_old_AEI_INFORMATION2,
                                     p_new_AEI_INFORMATION2,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_INFORMATION20',
                                     p_old_AEI_INFORMATION20,
                                     p_new_AEI_INFORMATION20,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_INFORMATION21',
                                     p_old_AEI_INFORMATION21,
                                     p_new_AEI_INFORMATION21,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_INFORMATION22',
                                     p_old_AEI_INFORMATION22,
                                     p_new_AEI_INFORMATION22,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_INFORMATION23',
                                     p_old_AEI_INFORMATION23,
                                     p_new_AEI_INFORMATION23,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_INFORMATION24',
                                     p_old_AEI_INFORMATION24,
                                     p_new_AEI_INFORMATION24,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_INFORMATION25',
                                     p_old_AEI_INFORMATION25,
                                     p_new_AEI_INFORMATION25,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_INFORMATION26',
                                     p_old_AEI_INFORMATION26,
                                     p_new_AEI_INFORMATION26,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_INFORMATION27',
                                     p_old_AEI_INFORMATION27,
                                     p_new_AEI_INFORMATION27,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_INFORMATION28',
                                     p_old_AEI_INFORMATION28,
                                     p_new_AEI_INFORMATION28,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_INFORMATION29',
                                     p_old_AEI_INFORMATION29,
                                     p_new_AEI_INFORMATION29,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_INFORMATION3',
                                     p_old_AEI_INFORMATION3,
                                     p_new_AEI_INFORMATION3,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_INFORMATION30',
                                     p_old_AEI_INFORMATION30,
                                     p_new_AEI_INFORMATION30,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_INFORMATION4',
                                     p_old_AEI_INFORMATION4,
                                     p_new_AEI_INFORMATION4,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_INFORMATION5',
                                     p_old_AEI_INFORMATION5,
                                     p_new_AEI_INFORMATION5,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_INFORMATION6',
                                     p_old_AEI_INFORMATION6,
                                     p_new_AEI_INFORMATION6,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_INFORMATION7',
                                     p_old_AEI_INFORMATION7,
                                     p_new_AEI_INFORMATION7,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_INFORMATION8',
                                     p_old_AEI_INFORMATION8,
                                     p_new_AEI_INFORMATION8,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_INFORMATION9',
                                     p_old_AEI_INFORMATION9,
                                     p_new_AEI_INFORMATION9,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'AEI_INFORMATION_CATEGORY',
                                     p_old_AEI_INFORMATION_CATEGORY,
                                     p_new_AEI_INFORMATION_CATEGORY,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'ASSIGNMENT_EXTRA_INFO_ID',
                                     p_old_ASSIGNMENT_EXTRA_INFO_ID,
                                     p_new_ASSIGNMENT_EXTRA_INFO_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'ASSIGNMENT_ID',
                                     p_old_ASSIGNMENT_ID,
                                     p_new_ASSIGNMENT_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     'INFORMATION_TYPE',
                                     p_old_INFORMATION_TYPE,
                                     p_new_INFORMATION_TYPE,
                                     p_effective_date
                                  );
--
   /* Now call the API for the affected assignments */
   declare
     l_process_event_id      number;
     l_object_version_number number;
     cnt number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
       for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
             p_assignment_id         => p_new_assignment_id,
             p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
             p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
             p_status                => 'U',
             p_description           => pay_continuous_calc.g_event_list.description(cnt),
             p_process_event_id      => l_process_event_id,
             p_object_version_number => l_object_version_number,
             p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
             p_business_group_id     => p_business_group_id,
             p_calculation_date      => pay_continuous_calc.g_event_list.calc_date(cnt),
             p_surrogate_key         => p_new_assignment_extra_info_id
           );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
--
end PER_ASSIGNMENT_EXTRA_INFO_aru;
--
/* PER_ASSIGNMENT_EXTRA_INFO_ari */
/* name : PER_ASSIGNMENT_EXTRA_INFO_ari
   purpose : This is procedure that records any insert
             on assignment extra information.
*/
PROCEDURE PER_ASSIGNMENT_EXTRA_INFO_ari(  p_business_group_id       in number,
                                         p_legislation_code         in varchar2,
                                         p_assignment_id            in number,
                                         p_assignment_extra_info_id in number,
                                         p_effective_start_date     in date
                                        )
IS
  --
  l_process_event_id      number;
  l_object_version_number number;
  l_proc varchar2(240) := g_package||'.PER_ASSIGNMENT_EXTRA_INFO_ari';
  --
BEGIN
  --
  hr_utility.set_location(l_proc, 10);
  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
  --
  pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     NULL,
                                     NULL,
                                     NULL,
                                     p_effective_start_date,
                                     p_effective_start_date,
                                     'I'
                                    );
  /* Now call the API for the affected assignments */
  DECLARE
    cnt number;
    l_process_event_id number;
    l_object_version_number number;
  BEGIN
    IF (pay_continuous_calc.g_event_list.sz <> 0) THEN
      --
        FOR cnt in 1..pay_continuous_calc.g_event_list.sz LOOP
          --
          pay_ppe_api.create_process_event(
             p_assignment_id         => p_assignment_id,
             p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
             p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
             p_status                => 'U',
             p_description           => pay_continuous_calc.g_event_list.description(cnt),
             p_process_event_id      => l_process_event_id,
             p_object_version_number => l_object_version_number,
             p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
             p_business_group_id     => p_business_group_id,
             p_calculation_date      => pay_continuous_calc.g_event_list.calc_date(cnt),
             p_surrogate_key         => p_assignment_extra_info_id);
          --
        END LOOP;
        --
    END IF;
    --
    pay_continuous_calc.g_event_list.sz := 0;
    --
  END;
  --
  hr_utility.set_location(l_proc, 900);
  --
END PER_ASSIGNMENT_EXTRA_INFO_ari;
--
/* name : PER_ASSIGNMENT_EXTRA_INFO_ard
   purpose : This is procedure that records any deletes
             on PER_ASSIGNMENT_EXTRA_INFO.
*/
  procedure PER_ASSIGNMENT_EXTRA_INFO_ard(
                       p_business_group_id in number,
                       p_legislation_code in varchar2,
                       p_assignment_id in number,
                       p_effective_start_date in date,
                       p_assignment_extra_info_id in number
                       )
  is
  --
  cursor asgcur (p_person_id number) is
  select distinct assignment_id
    from per_all_assignments_f
   where person_id = p_person_id;
   --
    l_process_event_id number;
    l_object_version_number number;
    l_proc varchar2(240) := g_package||'.PER_ASSIGNMENT_EXTRA_INFO_ard';
  begin
  hr_utility.set_location(l_proc, 10);
  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
--
-- Date column notional as this is a non-datetrack table
-- See pycodtrg.ldt to see which value is used as 'effective_start_date'
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ASSIGNMENT_EXTRA_INFO',
                                     NULL,
                                     NULL,
                                     NULL,
                                     p_effective_start_date,
                                     p_effective_start_date,
                                     'D'
                                    );
   /* Now call the API for the affected assignments */
   declare
     cnt number;
     l_process_event_id number;
     l_object_version_number number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                         p_assignment_id         => p_assignment_id,
                         p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
                         p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
                         p_status                => 'U',
                         p_description           => pay_continuous_calc.g_event_list.description(cnt),
                         p_process_event_id      => l_process_event_id,
                         p_object_version_number => l_object_version_number,
                         p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
                         p_surrogate_key         => p_assignment_extra_info_id,
                         p_calculation_date      => pay_continuous_calc.g_event_list.calc_date(cnt),
                         p_business_group_id     => p_business_group_id
                         );
          --
        END LOOP;
        --
    END IF;
    --
    pay_continuous_calc.g_event_list.sz := 0;
    --
  END;
  --
  hr_utility.set_location(l_proc, 900);
  --
END PER_ASSIGNMENT_EXTRA_INFO_ard;
--
/* name : per_periods_of_placement_aru
   purpose : This is the procedure that records any updates
             on per_periods_of_placement.
*/
procedure PER_PERIODS_OF_PLACEMENT_aru(
    p_business_group_id in number,
    p_legislation_code in varchar2,
    p_effective_date in date,
    p_old_ACTUAL_TERMINATION_DATE in DATE,
    p_new_ACTUAL_TERMINATION_DATE in DATE,
    p_old_ATTRIBUTE1 in VARCHAR2,
    p_new_ATTRIBUTE1 in VARCHAR2,
    p_old_ATTRIBUTE10 in VARCHAR2,
    p_new_ATTRIBUTE10 in VARCHAR2,
    p_old_ATTRIBUTE11 in VARCHAR2,
    p_new_ATTRIBUTE11 in VARCHAR2,
    p_old_ATTRIBUTE12 in VARCHAR2,
    p_new_ATTRIBUTE12 in VARCHAR2,
    p_old_ATTRIBUTE13 in VARCHAR2,
    p_new_ATTRIBUTE13 in VARCHAR2,
    p_old_ATTRIBUTE14 in VARCHAR2,
    p_new_ATTRIBUTE14 in VARCHAR2,
    p_old_ATTRIBUTE15 in VARCHAR2,
    p_new_ATTRIBUTE15 in VARCHAR2,
    p_old_ATTRIBUTE16 in VARCHAR2,
    p_new_ATTRIBUTE16 in VARCHAR2,
    p_old_ATTRIBUTE17 in VARCHAR2,
    p_new_ATTRIBUTE17 in VARCHAR2,
    p_old_ATTRIBUTE18 in VARCHAR2,
    p_new_ATTRIBUTE18 in VARCHAR2,
    p_old_ATTRIBUTE19 in VARCHAR2,
    p_new_ATTRIBUTE19 in VARCHAR2,
    p_old_ATTRIBUTE2 in VARCHAR2,
    p_new_ATTRIBUTE2 in VARCHAR2,
    p_old_ATTRIBUTE20 in VARCHAR2,
    p_new_ATTRIBUTE20 in VARCHAR2,
    p_old_ATTRIBUTE21 in VARCHAR2,
    p_new_ATTRIBUTE21 in VARCHAR2,
    p_old_ATTRIBUTE22 in VARCHAR2,
    p_new_ATTRIBUTE22 in VARCHAR2,
    p_old_ATTRIBUTE23 in VARCHAR2,
    p_new_ATTRIBUTE23 in VARCHAR2,
    p_old_ATTRIBUTE24 in VARCHAR2,
    p_new_ATTRIBUTE24 in VARCHAR2,
    p_old_ATTRIBUTE25 in VARCHAR2,
    p_new_ATTRIBUTE25 in VARCHAR2,
    p_old_ATTRIBUTE26 in VARCHAR2,
    p_new_ATTRIBUTE26 in VARCHAR2,
    p_old_ATTRIBUTE27 in VARCHAR2,
    p_new_ATTRIBUTE27 in VARCHAR2,
    p_old_ATTRIBUTE28 in VARCHAR2,
    p_new_ATTRIBUTE28 in VARCHAR2,
    p_old_ATTRIBUTE29 in VARCHAR2,
    p_new_ATTRIBUTE29 in VARCHAR2,
    p_old_ATTRIBUTE3 in VARCHAR2,
    p_new_ATTRIBUTE3 in VARCHAR2,
    p_old_ATTRIBUTE30 in VARCHAR2,
    p_new_ATTRIBUTE30 in VARCHAR2,
    p_old_ATTRIBUTE4 in VARCHAR2,
    p_new_ATTRIBUTE4 in VARCHAR2,
    p_old_ATTRIBUTE5 in VARCHAR2,
    p_new_ATTRIBUTE5 in VARCHAR2,
    p_old_ATTRIBUTE6 in VARCHAR2,
    p_new_ATTRIBUTE6 in VARCHAR2,
    p_old_ATTRIBUTE7 in VARCHAR2,
    p_new_ATTRIBUTE7 in VARCHAR2,
    p_old_ATTRIBUTE8 in VARCHAR2,
    p_new_ATTRIBUTE8 in VARCHAR2,
    p_old_ATTRIBUTE9 in VARCHAR2,
    p_new_ATTRIBUTE9 in VARCHAR2,
    p_old_ATTRIBUTE_CATEGORY in VARCHAR2,
    p_new_ATTRIBUTE_CATEGORY in VARCHAR2,
    p_old_BUSINESS_GROUP_ID in NUMBER,
    p_new_BUSINESS_GROUP_ID in NUMBER,
    p_old_FINAL_PROCESS_DATE in DATE,
    p_new_FINAL_PROCESS_DATE in DATE,
    p_old_INFORMATION1 in VARCHAR2,
    p_new_INFORMATION1 in VARCHAR2,
    p_old_INFORMATION10 in VARCHAR2,
    p_new_INFORMATION10 in VARCHAR2,
    p_old_INFORMATION11 in VARCHAR2,
    p_new_INFORMATION11 in VARCHAR2,
    p_old_INFORMATION12 in VARCHAR2,
    p_new_INFORMATION12 in VARCHAR2,
    p_old_INFORMATION13 in VARCHAR2,
    p_new_INFORMATION13 in VARCHAR2,
    p_old_INFORMATION14 in VARCHAR2,
    p_new_INFORMATION14 in VARCHAR2,
    p_old_INFORMATION15 in VARCHAR2,
    p_new_INFORMATION15 in VARCHAR2,
    p_old_INFORMATION16 in VARCHAR2,
    p_new_INFORMATION16 in VARCHAR2,
    p_old_INFORMATION17 in VARCHAR2,
    p_new_INFORMATION17 in VARCHAR2,
    p_old_INFORMATION18 in VARCHAR2,
    p_new_INFORMATION18 in VARCHAR2,
    p_old_INFORMATION19 in VARCHAR2,
    p_new_INFORMATION19 in VARCHAR2,
    p_old_INFORMATION2 in VARCHAR2,
    p_new_INFORMATION2 in VARCHAR2,
    p_old_INFORMATION20 in VARCHAR2,
    p_new_INFORMATION20 in VARCHAR2,
    p_old_INFORMATION21 in VARCHAR2,
    p_new_INFORMATION21 in VARCHAR2,
    p_old_INFORMATION22 in VARCHAR2,
    p_new_INFORMATION22 in VARCHAR2,
    p_old_INFORMATION23 in VARCHAR2,
    p_new_INFORMATION23 in VARCHAR2,
    p_old_INFORMATION24 in VARCHAR2,
    p_new_INFORMATION24 in VARCHAR2,
    p_old_INFORMATION25 in VARCHAR2,
    p_new_INFORMATION25 in VARCHAR2,
    p_old_INFORMATION26 in VARCHAR2,
    p_new_INFORMATION26 in VARCHAR2,
    p_old_INFORMATION27 in VARCHAR2,
    p_new_INFORMATION27 in VARCHAR2,
    p_old_INFORMATION28 in VARCHAR2,
    p_new_INFORMATION28 in VARCHAR2,
    p_old_INFORMATION29 in VARCHAR2,
    p_new_INFORMATION29 in VARCHAR2,
    p_old_INFORMATION3 in VARCHAR2,
    p_new_INFORMATION3 in VARCHAR2,
    p_old_INFORMATION30 in VARCHAR2,
    p_new_INFORMATION30 in VARCHAR2,
    p_old_INFORMATION4 in VARCHAR2,
    p_new_INFORMATION4 in VARCHAR2,
    p_old_INFORMATION5 in VARCHAR2,
    p_new_INFORMATION5 in VARCHAR2,
    p_old_INFORMATION6 in VARCHAR2,
    p_new_INFORMATION6 in VARCHAR2,
    p_old_INFORMATION7 in VARCHAR2,
    p_new_INFORMATION7 in VARCHAR2,
    p_old_INFORMATION8 in VARCHAR2,
    p_new_INFORMATION8 in VARCHAR2,
    p_old_INFORMATION9 in VARCHAR2,
    p_new_INFORMATION9 in VARCHAR2,
    p_old_INFORMATION_CATEGORY in VARCHAR2,
    p_new_INFORMATION_CATEGORY in VARCHAR2,
    p_old_LAST_STANDARD_PROCESS_DA in DATE,
    p_new_LAST_STANDARD_PROCESS_DA in DATE,
    p_old_PERIOD_OF_PLACEMENT_ID in NUMBER,
    p_new_PERIOD_OF_PLACEMENT_ID in NUMBER,
    p_old_PERSON_ID in NUMBER,
    p_new_PERSON_ID in NUMBER,
    p_old_PROJECTED_TERMINATION_DA in DATE,
    p_new_PROJECTED_TERMINATION_DA in DATE,
    p_old_TERMINATION_REASON in VARCHAR2,
    p_new_TERMINATION_REASON in VARCHAR2,
    p_old_DATE_START in DATE,
    p_new_DATE_START in DATE
)
is
--
  cursor asgcur (p_person_id number) is
  select distinct assignment_id
    from per_all_assignments_f
   where person_id = p_person_id;
  l_proc varchar2(240);

begin
  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
  --
  l_proc := g_package||'.per_periods_of_service_aru';
--
  /* If the dates havent changed it must be a correction */
  --
  -- We are assuming always a CORRECTION as non-datetracked table!
  --
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'ACTUAL_TERMINATION_DATE',
                                     p_old_ACTUAL_TERMINATION_DATE,
                                     p_new_ACTUAL_TERMINATION_DATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'ATTRIBUTE1',
                                     p_old_ATTRIBUTE1,
                                     p_new_ATTRIBUTE1,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'ATTRIBUTE10',
                                     p_old_ATTRIBUTE10,
                                     p_new_ATTRIBUTE10,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'ATTRIBUTE11',
                                     p_old_ATTRIBUTE11,
                                     p_new_ATTRIBUTE11,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'ATTRIBUTE12',
                                     p_old_ATTRIBUTE12,
                                     p_new_ATTRIBUTE12,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'ATTRIBUTE13',
                                     p_old_ATTRIBUTE13,
                                     p_new_ATTRIBUTE13,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'ATTRIBUTE14',
                                     p_old_ATTRIBUTE14,
                                     p_new_ATTRIBUTE14,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'ATTRIBUTE15',
                                     p_old_ATTRIBUTE15,
                                     p_new_ATTRIBUTE15,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'ATTRIBUTE16',
                                     p_old_ATTRIBUTE16,
                                     p_new_ATTRIBUTE16,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'ATTRIBUTE17',
                                     p_old_ATTRIBUTE17,
                                     p_new_ATTRIBUTE17,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'ATTRIBUTE18',
                                     p_old_ATTRIBUTE18,
                                     p_new_ATTRIBUTE18,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'ATTRIBUTE19',
                                     p_old_ATTRIBUTE19,
                                     p_new_ATTRIBUTE19,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'ATTRIBUTE2',
                                     p_old_ATTRIBUTE2,
                                     p_new_ATTRIBUTE2,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'ATTRIBUTE20',
                                     p_old_ATTRIBUTE20,
                                     p_new_ATTRIBUTE20,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'ATTRIBUTE21',
                                     p_old_ATTRIBUTE21,
                                     p_new_ATTRIBUTE21,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'ATTRIBUTE22',
                                     p_old_ATTRIBUTE22,
                                     p_new_ATTRIBUTE22,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'ATTRIBUTE23',
                                     p_old_ATTRIBUTE23,
                                     p_new_ATTRIBUTE23,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'ATTRIBUTE24',
                                     p_old_ATTRIBUTE24,
                                     p_new_ATTRIBUTE24,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'ATTRIBUTE25',
                                     p_old_ATTRIBUTE25,
                                     p_new_ATTRIBUTE25,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'ATTRIBUTE26',
                                     p_old_ATTRIBUTE26,
                                     p_new_ATTRIBUTE26,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'ATTRIBUTE27',
                                     p_old_ATTRIBUTE27,
                                     p_new_ATTRIBUTE27,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'ATTRIBUTE28',
                                     p_old_ATTRIBUTE28,
                                     p_new_ATTRIBUTE28,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'ATTRIBUTE29',
                                     p_old_ATTRIBUTE29,
                                     p_new_ATTRIBUTE29,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'ATTRIBUTE3',
                                     p_old_ATTRIBUTE3,
                                     p_new_ATTRIBUTE3,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'ATTRIBUTE30',
                                     p_old_ATTRIBUTE30,
                                     p_new_ATTRIBUTE30,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'ATTRIBUTE4',
                                     p_old_ATTRIBUTE4,
                                     p_new_ATTRIBUTE4,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'ATTRIBUTE5',
                                     p_old_ATTRIBUTE5,
                                     p_new_ATTRIBUTE5,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'ATTRIBUTE6',
                                     p_old_ATTRIBUTE6,
                                     p_new_ATTRIBUTE6,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'ATTRIBUTE7',
                                     p_old_ATTRIBUTE7,
                                     p_new_ATTRIBUTE7,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'ATTRIBUTE8',
                                     p_old_ATTRIBUTE8,
                                     p_new_ATTRIBUTE8,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'ATTRIBUTE9',
                                     p_old_ATTRIBUTE9,
                                     p_new_ATTRIBUTE9,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'ATTRIBUTE_CATEGORY',
                                     p_old_ATTRIBUTE_CATEGORY,
                                     p_new_ATTRIBUTE_CATEGORY,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'BUSINESS_GROUP_ID',
                                     p_old_BUSINESS_GROUP_ID,
                                     p_new_BUSINESS_GROUP_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'FINAL_PROCESS_DATE',
                                     p_old_FINAL_PROCESS_DATE,
                                     p_new_FINAL_PROCESS_DATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'INFORMATION1',
                                     p_old_INFORMATION1,
                                     p_new_INFORMATION1,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'INFORMATION10',
                                     p_old_INFORMATION10,
                                     p_new_INFORMATION10,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'INFORMATION11',
                                     p_old_INFORMATION11,
                                     p_new_INFORMATION11,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'INFORMATION12',
                                     p_old_INFORMATION12,
                                     p_new_INFORMATION12,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'INFORMATION13',
                                     p_old_INFORMATION13,
                                     p_new_INFORMATION13,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'INFORMATION14',
                                     p_old_INFORMATION14,
                                     p_new_INFORMATION14,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'INFORMATION15',
                                     p_old_INFORMATION15,
                                     p_new_INFORMATION15,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'INFORMATION16',
                                     p_old_INFORMATION16,
                                     p_new_INFORMATION16,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'INFORMATION17',
                                     p_old_INFORMATION17,
                                     p_new_INFORMATION17,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'INFORMATION18',
                                     p_old_INFORMATION18,
                                     p_new_INFORMATION18,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'INFORMATION19',
                                     p_old_INFORMATION19,
                                     p_new_INFORMATION19,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'INFORMATION2',
                                     p_old_INFORMATION2,
                                     p_new_INFORMATION2,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'INFORMATION20',
                                     p_old_INFORMATION20,
                                     p_new_INFORMATION20,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'INFORMATION21',
                                     p_old_INFORMATION21,
                                     p_new_INFORMATION21,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'INFORMATION22',
                                     p_old_INFORMATION22,
                                     p_new_INFORMATION22,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'INFORMATION23',
                                     p_old_INFORMATION23,
                                     p_new_INFORMATION23,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'INFORMATION24',
                                     p_old_INFORMATION24,
                                     p_new_INFORMATION24,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'INFORMATION25',
                                     p_old_INFORMATION25,
                                     p_new_INFORMATION25,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'INFORMATION26',
                                     p_old_INFORMATION26,
                                     p_new_INFORMATION26,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'INFORMATION27',
                                     p_old_INFORMATION27,
                                     p_new_INFORMATION27,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'INFORMATION28',
                                     p_old_INFORMATION28,
                                     p_new_INFORMATION28,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'INFORMATION29',
                                     p_old_INFORMATION29,
                                     p_new_INFORMATION29,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'INFORMATION3',
                                     p_old_INFORMATION3,
                                     p_new_INFORMATION3,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'INFORMATION30',
                                     p_old_INFORMATION30,
                                     p_new_INFORMATION30,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'INFORMATION4',
                                     p_old_INFORMATION4,
                                     p_new_INFORMATION4,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'INFORMATION5',
                                     p_old_INFORMATION5,
                                     p_new_INFORMATION5,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'INFORMATION6',
                                     p_old_INFORMATION6,
                                     p_new_INFORMATION6,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'INFORMATION7',
                                     p_old_INFORMATION7,
                                     p_new_INFORMATION7,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'INFORMATION8',
                                     p_old_INFORMATION8,
                                     p_new_INFORMATION8,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'INFORMATION9',
                                     p_old_INFORMATION9,
                                     p_new_INFORMATION9,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'INFORMATION_CATEGORY',
                                     p_old_INFORMATION_CATEGORY,
                                     p_new_INFORMATION_CATEGORY,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'LAST_STANDARD_PROCESS_DATE',
                                     p_old_LAST_STANDARD_PROCESS_DA,
                                     p_new_LAST_STANDARD_PROCESS_DA,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'PERIOD_OF_PLACEMENT_ID',
                                     p_old_PERIOD_OF_PLACEMENT_ID,
                                     p_new_PERIOD_OF_PLACEMENT_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'PERSON_ID',
                                     p_old_PERSON_ID,
                                     p_new_PERSON_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'PROJECTED_TERMINATION_DATE',
                                     p_old_PROJECTED_TERMINATION_DA,
                                     p_new_PROJECTED_TERMINATION_DA,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'TERMINATION_REASON',
                                     p_old_TERMINATION_REASON,
                                     p_new_TERMINATION_REASON,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_PERIODS_OF_PLACEMENT',
                                     'DATE_START',
                                     p_old_DATE_START,
                                     p_new_DATE_START,
                                     p_effective_date
                                  );
--
   /* Now call the API for the affected assignments */
   declare
     l_process_event_id      number;
     l_object_version_number number;
     cnt number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
       for asgrec in asgcur (p_old_PERSON_ID) loop
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
             p_assignment_id         => asgrec.assignment_id,
             p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
             p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
             p_status                => 'U',
             p_description           => pay_continuous_calc.g_event_list.description(cnt),
             p_process_event_id      => l_process_event_id,
             p_object_version_number => l_object_version_number,
             p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
             p_business_group_id     => p_business_group_id,
             p_calculation_date      => pay_continuous_calc.g_event_list.calc_date(cnt),
             p_surrogate_key         => p_new_period_of_placement_id
           );
         end loop;
       end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
--
end PER_PERIODS_OF_PLACEMENT_aru;
--
procedure PER_ABSENCE_ATTENDANCES_aru(
    p_business_group_id in number,
    p_legislation_code in varchar2,
    p_effective_date in date,
    p_old_ABSENCE_ATTENDANCE_ID  in NUMBER,
    p_new_ABSENCE_ATTENDANCE_ID  in NUMBER,
    p_old_PERSON_ID  in NUMBER,
    p_new_PERSON_ID  in NUMBER,
    p_old_ABS_ATTENDANCE_REASON_ID  in NUMBER,
    p_new_ABS_ATTENDANCE_REASON_ID  in NUMBER,
    p_old_AUTHORISING_PERSON_ID  in NUMBER,
    p_new_AUTHORISING_PERSON_ID  in NUMBER,
    p_old_REPLACEMENT_PERSON_ID  in NUMBER,
    p_new_REPLACEMENT_PERSON_ID  in NUMBER,
    p_old_PERIOD_OF_INCAPACITY_ID  in NUMBER,
    p_new_PERIOD_OF_INCAPACITY_ID  in NUMBER,
    p_old_ABSENCE_DAYS  in NUMBER,
    p_new_ABSENCE_DAYS  in NUMBER,
    p_old_ABSENCE_HOURS  in NUMBER,
    p_new_ABSENCE_HOURS  in NUMBER,
    p_old_DATE_END  in DATE,
    p_new_DATE_END  in DATE,
    p_old_DATE_NOTIFICATION  in DATE,
    p_new_DATE_NOTIFICATION  in DATE,
    p_old_DATE_PROJECTED_END  in DATE,
    p_new_DATE_PROJECTED_END  in DATE,
    p_old_DATE_PROJECTED_START  in DATE,
    p_new_DATE_PROJECTED_START  in DATE,
    p_old_DATE_START  in DATE,
    p_new_DATE_START  in DATE,
    p_old_SSP1_ISSUED  in VARCHAR2,
    p_new_SSP1_ISSUED  in VARCHAR2,
    p_old_TIME_END  in VARCHAR2,
    p_new_TIME_END  in VARCHAR2,
    p_old_TIME_PROJECTED_END  in VARCHAR2,
    p_new_TIME_PROJECTED_END  in VARCHAR2,
    p_old_TIME_PROJECTED_START  in VARCHAR2,
    p_new_TIME_PROJECTED_START  in VARCHAR2,
    p_old_TIME_START  in VARCHAR2,
    p_new_TIME_START  in VARCHAR2,
    p_old_MATERNITY_ID  in NUMBER,
    p_new_MATERNITY_ID  in NUMBER,
    p_old_SICKNESS_START_DATE  in DATE,
    p_new_SICKNESS_START_DATE  in DATE,
    p_old_SICKNESS_END_DATE  in DATE,
    p_new_SICKNESS_END_DATE  in DATE,
    p_old_LINKED_ABSENCE_ID  in NUMBER,
    p_new_LINKED_ABSENCE_ID  in NUMBER,
    p_old_ATTRIBUTE1 in VARCHAR2,
    p_new_ATTRIBUTE1 in VARCHAR2,
    p_old_ATTRIBUTE2 in VARCHAR2,
    p_new_ATTRIBUTE2 in VARCHAR2,
    p_old_ATTRIBUTE3 in VARCHAR2,
    p_new_ATTRIBUTE3 in VARCHAR2,
    p_old_ATTRIBUTE4 in VARCHAR2,
    p_new_ATTRIBUTE4 in VARCHAR2,
    p_old_ATTRIBUTE5 in VARCHAR2,
    p_new_ATTRIBUTE5 in VARCHAR2,
    p_old_ATTRIBUTE6 in VARCHAR2,
    p_new_ATTRIBUTE6 in VARCHAR2,
    p_old_ATTRIBUTE7 in VARCHAR2,
    p_new_ATTRIBUTE7 in VARCHAR2,
    p_old_ATTRIBUTE8 in VARCHAR2,
    p_new_ATTRIBUTE8 in VARCHAR2,
    p_old_ATTRIBUTE9 in VARCHAR2,
    p_new_ATTRIBUTE9 in VARCHAR2,
    p_old_ATTRIBUTE10 in VARCHAR2,
    p_new_ATTRIBUTE10 in VARCHAR2,
    p_old_ATTRIBUTE11 in VARCHAR2,
    p_new_ATTRIBUTE11 in VARCHAR2,
    p_old_ATTRIBUTE12 in VARCHAR2,
    p_new_ATTRIBUTE12 in VARCHAR2,
    p_old_ATTRIBUTE13 in VARCHAR2,
    p_new_ATTRIBUTE13 in VARCHAR2,
    p_old_ATTRIBUTE14 in VARCHAR2,
    p_new_ATTRIBUTE14 in VARCHAR2,
    p_old_ATTRIBUTE15 in VARCHAR2,
    p_new_ATTRIBUTE15 in VARCHAR2,
    p_old_ATTRIBUTE16 in VARCHAR2,
    p_new_ATTRIBUTE16 in VARCHAR2,
    p_old_ATTRIBUTE17 in VARCHAR2,
    p_new_ATTRIBUTE17 in VARCHAR2,
    p_old_ATTRIBUTE18 in VARCHAR2,
    p_new_ATTRIBUTE18 in VARCHAR2,
    p_old_ATTRIBUTE19 in VARCHAR2,
    p_new_ATTRIBUTE19 in VARCHAR2,
    p_old_ATTRIBUTE20 in VARCHAR2,
    p_new_ATTRIBUTE20 in VARCHAR2,
    p_old_ATTRIBUTE_CATEGORY in VARCHAR2,
    p_new_ATTRIBUTE_CATEGORY in VARCHAR2
) IS
--
  cursor asgcur (p_person_id number) is
  select distinct assignment_id
    from per_all_assignments_f
   where person_id = p_person_id
   and primary_flag = 'Y';
  --
  l_proc varchar2(240) := g_package||'.per_absence_attendances_aru';
  l_effective_date    DATE;
begin
  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
--
-- Default effective date
--
  IF (p_effective_date IS NULL) THEN
    l_effective_date := trunc(sysdate);
  ELSE
    l_effective_date := p_effective_date;
  END IF;
--
-- Always assume update is correction
--
    pay_continuous_calc.event_update
     (p_business_group_id,
      p_legislation_code,
      'PER_ABSENCE_ATTENDANCES',
      'ABSENCE_ATTENDANCE_ID',
      p_old_ABSENCE_ATTENDANCE_ID,
      p_new_ABSENCE_ATTENDANCE_ID,
      l_effective_date);

    pay_continuous_calc.event_update
     (p_business_group_id,
      p_legislation_code,
      'PER_ABSENCE_ATTENDANCES',
      'ABS_ATTENDANCE_REASON_ID',
      p_old_ABS_ATTENDANCE_REASON_ID,
      p_new_ABS_ATTENDANCE_REASON_ID,
      l_effective_date);

    pay_continuous_calc.event_update
     (p_business_group_id,
      p_legislation_code,
      'PER_ABSENCE_ATTENDANCES',
      'AUTHORISING_PERSON_ID',
      p_old_AUTHORISING_PERSON_ID,
      p_new_AUTHORISING_PERSON_ID,
      l_effective_date);

    pay_continuous_calc.event_update
     (p_business_group_id,
      p_legislation_code,
      'PER_ABSENCE_ATTENDANCES',
      'REPLACEMENT_PERSON_ID',
      p_old_REPLACEMENT_PERSON_ID,
      p_new_REPLACEMENT_PERSON_ID,
      l_effective_date);

    pay_continuous_calc.event_update
     (p_business_group_id,
      p_legislation_code,
      'PER_ABSENCE_ATTENDANCES',
      'PERIOD_OF_INCAPACITY_ID',
      p_old_PERIOD_OF_INCAPACITY_ID,
      p_new_PERIOD_OF_INCAPACITY_ID,
      l_effective_date);

    pay_continuous_calc.event_update
     (p_business_group_id,
      p_legislation_code,
      'PER_ABSENCE_ATTENDANCES',
      'ABSENCE_DAYS',
      p_old_ABSENCE_DAYS,
      p_new_ABSENCE_DAYS,
      l_effective_date);

    pay_continuous_calc.event_update
     (p_business_group_id,
      p_legislation_code,
      'PER_ABSENCE_ATTENDANCES',
      'ABSENCE_HOURS',
      p_old_ABSENCE_HOURS,
      p_new_ABSENCE_HOURS,
      l_effective_date);

    pay_continuous_calc.event_update
     (p_business_group_id,
      p_legislation_code,
      'PER_ABSENCE_ATTENDANCES',
      'DATE_END',
      p_old_DATE_END,
      p_new_DATE_END,
      l_effective_date);

    pay_continuous_calc.event_update
     (p_business_group_id,
      p_legislation_code,
      'PER_ABSENCE_ATTENDANCES',
      'DATE_NOTIFICATION',
      p_old_DATE_NOTIFICATION,
      p_new_DATE_NOTIFICATION,
      l_effective_date);

    pay_continuous_calc.event_update
     (p_business_group_id,
      p_legislation_code,
      'PER_ABSENCE_ATTENDANCES',
      'DATE_PROJECTED_END',
      p_old_DATE_PROJECTED_END,
      p_new_DATE_PROJECTED_END,
      l_effective_date);

    pay_continuous_calc.event_update
     (p_business_group_id,
      p_legislation_code,
      'PER_ABSENCE_ATTENDANCES',
      'DATE_PROJECTED_START',
      p_old_DATE_PROJECTED_START,
      p_new_DATE_PROJECTED_START,
      l_effective_date);

    pay_continuous_calc.event_update
     (p_business_group_id,
      p_legislation_code,
      'PER_ABSENCE_ATTENDANCES',
      'DATE_START',
      p_old_DATE_START,
      p_new_DATE_START,
      l_effective_date);

    pay_continuous_calc.event_update
     (p_business_group_id,
      p_legislation_code,
      'PER_ABSENCE_ATTENDANCES',
      'SSP1_ISSUED',
      p_old_SSP1_ISSUED,
      p_new_SSP1_ISSUED,
      l_effective_date);

    pay_continuous_calc.event_update
     (p_business_group_id,
      p_legislation_code,
      'PER_ABSENCE_ATTENDANCES',
      'TIME_END',
      p_old_TIME_END,
      p_new_TIME_END,
      l_effective_date);

    pay_continuous_calc.event_update
     (p_business_group_id,
      p_legislation_code,
      'PER_ABSENCE_ATTENDANCES',
      'TIME_PROJECTED_END',
      p_old_TIME_PROJECTED_END,
      p_new_TIME_PROJECTED_END,
      l_effective_date);

    pay_continuous_calc.event_update
     (p_business_group_id,
      p_legislation_code,
      'PER_ABSENCE_ATTENDANCES',
      'TIME_PROJECTED_START',
      p_old_TIME_PROJECTED_START,
      p_new_TIME_PROJECTED_START,
      l_effective_date);

    pay_continuous_calc.event_update
     (p_business_group_id,
      p_legislation_code,
      'PER_ABSENCE_ATTENDANCES',
      'TIME_START',
      p_old_TIME_START,
      p_new_TIME_START,
      l_effective_date);

    pay_continuous_calc.event_update
     (p_business_group_id,
      p_legislation_code,
      'PER_ABSENCE_ATTENDANCES',
      'MATERNITY_ID',
      p_old_MATERNITY_ID,
      p_new_MATERNITY_ID,
      l_effective_date);

    pay_continuous_calc.event_update
     (p_business_group_id,
      p_legislation_code,
      'PER_ABSENCE_ATTENDANCES',
      'SICKNESS_START_DATE',
      p_old_SICKNESS_START_DATE,
      p_new_SICKNESS_START_DATE,
      l_effective_date);

    pay_continuous_calc.event_update
     (p_business_group_id,
      p_legislation_code,
      'PER_ABSENCE_ATTENDANCES',
      'SICKNESS_END_DATE',
      p_old_SICKNESS_END_DATE,
      p_new_SICKNESS_END_DATE,
      l_effective_date);

    pay_continuous_calc.event_update
     (p_business_group_id,
      p_legislation_code,
      'PER_ABSENCE_ATTENDANCES',
      'LINKED_ABSENCE_ID',
      p_old_LINKED_ABSENCE_ID,
      p_new_LINKED_ABSENCE_ID,
      l_effective_date);
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ABSENCE_ATTENDANCES',
                                     'ATTRIBUTE1',
                                     p_old_ATTRIBUTE1,
                                     p_new_ATTRIBUTE1,
                                     l_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ABSENCE_ATTENDANCES',
                                     'ATTRIBUTE10',
                                     p_old_ATTRIBUTE10,
                                     p_new_ATTRIBUTE10,
                                     l_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ABSENCE_ATTENDANCES',
                                     'ATTRIBUTE11',
                                     p_old_ATTRIBUTE11,
                                     p_new_ATTRIBUTE11,
                                     l_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ABSENCE_ATTENDANCES',
                                     'ATTRIBUTE12',
                                     p_old_ATTRIBUTE12,
                                     p_new_ATTRIBUTE12,
                                     l_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ABSENCE_ATTENDANCES',
                                     'ATTRIBUTE13',
                                     p_old_ATTRIBUTE13,
                                     p_new_ATTRIBUTE13,
                                     l_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ABSENCE_ATTENDANCES',
                                     'ATTRIBUTE14',
                                     p_old_ATTRIBUTE14,
                                     p_new_ATTRIBUTE14,
                                     l_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ABSENCE_ATTENDANCES',
                                     'ATTRIBUTE15',
                                     p_old_ATTRIBUTE15,
                                     p_new_ATTRIBUTE15,
                                     l_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ABSENCE_ATTENDANCES',
                                     'ATTRIBUTE16',
                                     p_old_ATTRIBUTE16,
                                     p_new_ATTRIBUTE16,
                                     l_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ABSENCE_ATTENDANCES',
                                     'ATTRIBUTE17',
                                     p_old_ATTRIBUTE17,
                                     p_new_ATTRIBUTE17,
                                     l_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ABSENCE_ATTENDANCES',
                                     'ATTRIBUTE18',
                                     p_old_ATTRIBUTE18,
                                     p_new_ATTRIBUTE18,
                                     l_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ABSENCE_ATTENDANCES',
                                     'ATTRIBUTE19',
                                     p_old_ATTRIBUTE19,
                                     p_new_ATTRIBUTE19,
                                     l_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ABSENCE_ATTENDANCES',
                                     'ATTRIBUTE2',
                                     p_old_ATTRIBUTE2,
                                     p_new_ATTRIBUTE2,
                                     l_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ABSENCE_ATTENDANCES',
                                     'ATTRIBUTE20',
                                     p_old_ATTRIBUTE20,
                                     p_new_ATTRIBUTE20,
                                     l_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ABSENCE_ATTENDANCES',
                                     'ATTRIBUTE3',
                                     p_old_ATTRIBUTE3,
                                     p_new_ATTRIBUTE3,
                                     l_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ABSENCE_ATTENDANCES',
                                     'ATTRIBUTE4',
                                     p_old_ATTRIBUTE4,
                                     p_new_ATTRIBUTE4,
                                     l_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ABSENCE_ATTENDANCES',
                                     'ATTRIBUTE5',
                                     p_old_ATTRIBUTE5,
                                     p_new_ATTRIBUTE5,
                                     l_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ABSENCE_ATTENDANCES',
                                     'ATTRIBUTE6',
                                     p_old_ATTRIBUTE6,
                                     p_new_ATTRIBUTE6,
                                     l_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ABSENCE_ATTENDANCES',
                                     'ATTRIBUTE7',
                                     p_old_ATTRIBUTE7,
                                     p_new_ATTRIBUTE7,
                                     l_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ABSENCE_ATTENDANCES',
                                     'ATTRIBUTE8',
                                     p_old_ATTRIBUTE8,
                                     p_new_ATTRIBUTE8,
                                     l_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ABSENCE_ATTENDANCES',
                                     'ATTRIBUTE9',
                                     p_old_ATTRIBUTE9,
                                     p_new_ATTRIBUTE9,
                                     l_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ABSENCE_ATTENDANCES',
                                     'ATTRIBUTE_CATEGORY',
                                     p_old_ATTRIBUTE_CATEGORY,
                                     p_new_ATTRIBUTE_CATEGORY,
                                     l_effective_date
                                  );
--
   /* Now call the API for the affected assignments */
   declare
     l_process_event_id      number;
     l_object_version_number number;
     cnt number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
       for asgrec in asgcur(p_new_person_id) loop
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
             p_assignment_id         => asgrec.assignment_id,
             p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
             p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
             p_status                => 'U',
             p_description           => pay_continuous_calc.g_event_list.description(cnt),
             p_process_event_id      => l_process_event_id,
             p_object_version_number => l_object_version_number,
             p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
             p_business_group_id     => p_business_group_id,
             p_calculation_date      => pay_continuous_calc.g_event_list.calc_date(cnt),
             p_surrogate_key         => p_new_absence_attendance_id
           );
          --
        END LOOP;
        --
      END LOOP;
      --
    END IF;
    --
    pay_continuous_calc.g_event_list.sz := 0;
    --
  END;
--
END PER_ABSENCE_ATTENDANCES_aru;
--
procedure PER_ABSENCE_ATTENDANCES_ari
   (p_business_group_id in number,
    p_legislation_code in varchar2,
    p_person_id in number,
    p_absence_attendance_id in number,
    p_effective_start_date in date)
IS
  --
  cursor asgcur (p_person_id number) is
  select distinct assignment_id
    from per_all_assignments_f
   where person_id = p_person_id
   and primary_flag = 'Y';
   --
  l_process_event_id      number;
  l_object_version_number number;
  l_proc varchar2(240) := g_package||'.per_absence_attendances_ari';
  --
BEGIN
  --
  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
  --
  -- Date column notional as table is not date tracked
  --
  pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ABSENCE_ATTENDANCES',
                                     NULL,
                                     NULL,
                                     NULL,
                                     NVL(p_effective_start_date,TRUNC(SYSDATE)),
                                     NVL(p_effective_start_date,TRUNC(SYSDATE)),
                                     'I'
                                    );
  /* Now call the API for the affected assignments */
  DECLARE
    cnt number;
    l_process_event_id number;
    l_object_version_number number;
  BEGIN
    IF (pay_continuous_calc.g_event_list.sz <> 0) THEN
      --
      FOR asgrec in asgcur (p_person_id) LOOP
        --
        FOR cnt in 1..pay_continuous_calc.g_event_list.sz LOOP
          --
          pay_ppe_api.create_process_event(
             p_assignment_id         => asgrec.assignment_id,
             p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
             p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
             p_status                => 'U',
             p_description           => pay_continuous_calc.g_event_list.description(cnt),
             p_process_event_id      => l_process_event_id,
             p_object_version_number => l_object_version_number,
             p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
             p_business_group_id     => p_business_group_id,
             p_calculation_date      => pay_continuous_calc.g_event_list.calc_date(cnt),
             p_surrogate_key         => p_absence_attendance_id);
          --
        END LOOP;
        --
      END LOOP;
      --
    END IF;
    --
    pay_continuous_calc.g_event_list.sz := 0;
    --
  END;
  --
END per_absence_attendances_ari;
--
procedure PER_ABSENCE_ATTENDANCES_ard
   (p_business_group_id in number,
    p_legislation_code in varchar2,
    p_person_id in number,
    p_effective_start_date in date,
    p_absence_attendance_id in number)
IS
  --
  cursor asgcur (p_person_id number) is
  select distinct assignment_id
    from per_all_assignments_f
   where person_id = p_person_id
   and primary_flag = 'Y';
   --
    l_process_event_id number;
    l_object_version_number number;
    l_proc varchar2(240) := g_package||'.per_absence_attendances_ard';
  begin

  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
--
-- Date column notional as this is a non-datetrack table
-- See pycodtrg.ldt to see which value is used as 'effective_start_date'
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PER_ABSENCE_ATTENDANCES',
                                     NULL,
                                     NULL,
                                     NULL,
                                     NVL(p_effective_start_date,TRUNC(SYSDATE)),
                                     NVL(p_effective_start_date,TRUNC(SYSDATE)),
                                     'D'
                                    );
   /* Now call the API for the affected assignments */
   declare
     cnt number;
     l_process_event_id number;
     l_object_version_number number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
       for asgrec in asgcur (p_person_id) loop
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event
            (p_assignment_id         => asgrec.assignment_id,
             p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
             p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
             p_status                => 'U',
             p_description           => pay_continuous_calc.g_event_list.description(cnt),
             p_process_event_id      => l_process_event_id,
             p_object_version_number => l_object_version_number,
             p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
             p_surrogate_key         => p_absence_attendance_id,
             p_calculation_date      => pay_continuous_calc.g_event_list.calc_date(cnt),
             p_business_group_id     => p_business_group_id);
          --
        END LOOP;
        --
      END LOOP;
      --
    END IF;
    --
    pay_continuous_calc.g_event_list.sz := 0;
    --
  END;
  --
END per_absence_attendances_ard;


procedure PQP_GAP_DURATION_SUMMARY_ari
   (p_business_group_id in number ,
    p_legislation_code in varchar2,
    p_assignment_id in number,
    p_gap_duration_summary_id in number,
    p_effective_start_date in date)
IS


  l_process_event_id      number;
  l_object_version_number number;
  l_proc varchar2(240) := g_package||'.PQP_GAP_DURATION_SUMMARY_ari';
  --
BEGIN
  --
  /* If the continuous calc is overriden then do nothing */

  if (pay_continuous_calc.g_override_cc = TRUE) then
      return;
  end if;
  --
   pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PQP_GAP_DURATION_SUMMARY',
                                     NULL,
                                     NULL,
                                     NULL,
                                     p_effective_start_date,
                                     p_effective_start_date,
                                     'I'
                                    );
  /* Now call the API for the affected assignments */
  DECLARE
    cnt number;
    l_process_event_id number;
    l_object_version_number number;

  BEGIN

      IF (pay_continuous_calc.g_event_list.sz <> 0) THEN
      --
        FOR cnt in 1..pay_continuous_calc.g_event_list.sz LOOP
          --
            pay_ppe_api.create_process_event(
             p_assignment_id         => p_assignment_id,
             p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
             p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
             p_status                => 'U',
             p_description           => pay_continuous_calc.g_event_list.description(cnt),
             p_process_event_id      => l_process_event_id,
             p_object_version_number => l_object_version_number,
             p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
             p_business_group_id     => p_business_group_id,
             p_calculation_date      => pay_continuous_calc.g_event_list.calc_date(cnt),
             p_surrogate_key         => p_gap_duration_summary_id);
            --
        END LOOP;

      --
    END IF;
    --
    pay_continuous_calc.g_event_list.sz := 0;
    --
  END;
  --
END PQP_GAP_DURATION_SUMMARY_ari;
--

procedure PQP_GAP_DURATION_SUMMARY_aru(
    p_business_group_id in number,
    p_legislation_code in varchar2,
    P_GAP_DURATION_SUMMARY_ID in NUMBER,
    P_ASSIGNMENT_ID NUMBER,
    p_new_DURATION_IN_DAYS in NUMBER,
    p_old_DURATION_IN_DAYS in NUMBER,
    p_new_DURATION_IN_HOURS in NUMBER,
    p_old_DURATION_IN_HOURS in NUMBER,
    p_new_DATE_END  in DATE,
    p_old_DATE_END  in DATE,
    p_new_DATE_START  in DATE,
    p_old_DATE_START  in DATE,
    p_effective_date in DATE
    -- need to add date start as well
  ) IS
--

  --
  l_proc varchar2(240) := g_package||'.PQP_GAP_DURATION_SUMMARY_aru';
begin
  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
--
-- Always assume update is correction
--
    pay_continuous_calc.event_update
     (p_business_group_id,
      p_legislation_code,
      'PQP_GAP_DURATION_SUMMARY',
      'DURATION_IN_DAYS',
      p_old_DURATION_IN_DAYS,
      p_new_DURATION_IN_DAYS,
      p_effective_date);

    pay_continuous_calc.event_update
     (p_business_group_id,
      p_legislation_code,
      'PQP_GAP_DURATION_SUMMARY',
      'DURATION_IN_HOURS',
      p_old_DURATION_IN_HOURS,
      p_new_DURATION_IN_HOURS,
      p_effective_date);

    pay_continuous_calc.event_update
     (p_business_group_id,
      p_legislation_code,
      'PQP_GAP_DURATION_SUMMARY',
      'DATE_END',
      p_old_DATE_END,
      p_new_DATE_END,
      p_effective_date);

    pay_continuous_calc.event_update
     (p_business_group_id,
      p_legislation_code,
      'PQP_GAP_DURATION_SUMMARY',
      'DATE_START',
      p_old_DATE_START,
      p_new_DATE_START,
      p_effective_date);


    --
   /* Now call the API for the affected assignments */
   declare
     l_process_event_id      number;
     l_object_version_number number;
     cnt number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
             p_assignment_id         => P_ASSIGNMENT_ID,
             p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
             p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
             p_status                => 'U',
             p_description           => pay_continuous_calc.g_event_list.description(cnt),
             p_process_event_id      => l_process_event_id,
             p_object_version_number => l_object_version_number,
             p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
             p_business_group_id     => p_business_group_id,
             p_calculation_date      => pay_continuous_calc.g_event_list.calc_date(cnt),
             p_surrogate_key         => P_GAP_DURATION_SUMMARY_ID
           );
          --
        END LOOP;
        --
      --
    END IF;
    --
    pay_continuous_calc.g_event_list.sz := 0;
    --
  END;
--
END PQP_GAP_DURATION_SUMMARY_aru;

--

procedure PQP_GAP_DURATION_SUMMARY_ard
   (p_business_group_id in number,
    p_legislation_code in varchar2,
    P_GAP_DURATION_SUMMARY_ID in NUMBER,
    P_ASSIGNMENT_ID NUMBER,
    p_effective_start_date in date
    )
IS
  --
    --
    l_process_event_id number;
    l_object_version_number number;
    l_proc varchar2(240) := g_package||'.PQP_GAP_DURATION_SUMMARY_ard';
  begin

  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
--
-- Date column notional as this is a non-datetrack table
-- See pycodtrg.ldt to see which value is used as 'effective_start_date'
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PQP_GAP_DURATION_SUMMARY',
                                     NULL,
                                     NULL,
                                     NULL,
                                     p_effective_start_date,
                                     p_effective_start_date,
                                     'D'
                                    );
   /* Now call the API for the affected assignments */
   declare
     cnt number;
     l_process_event_id number;
     l_object_version_number number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then

        for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event
            (p_assignment_id         => P_ASSIGNMENT_ID,
             p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
             p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
             p_status                => 'U',
             p_description           => pay_continuous_calc.g_event_list.description(cnt),
             p_process_event_id      => l_process_event_id,
             p_object_version_number => l_object_version_number,
             p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
             p_surrogate_key         => P_GAP_DURATION_SUMMARY_ID,
             p_calculation_date      => pay_continuous_calc.g_event_list.calc_date(cnt),
             p_business_group_id     => p_business_group_id);
          --
        END LOOP;
        --
       --
    END IF;
    --
    pay_continuous_calc.g_event_list.sz := 0;
    --
  END;
  --
END PQP_GAP_DURATION_SUMMARY_ard;






--
begin
  pay_continuous_calc.g_event_list.sz := 0;
  pay_continuous_calc.g_override_cc := FALSE;
END PAY_MISC_DYT_INCIDENT_PKG;

/
