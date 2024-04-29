--------------------------------------------------------
--  DDL for Package Body PQP_GB_TP_EXTRACT_TRIGGERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_TP_EXTRACT_TRIGGERS" AS
--  /* $Header: pqpgbtpt.pkb 120.2.12010000.2 2009/06/30 10:42:00 dchindar ship $ */
--
--
--
   PROCEDURE pqp_assignment_attribute_f_aru
   (p_business_group_id in number
   ,p_legislation_code in varchar2
   ,p_effective_date in date
   ,p_old_AAT_ATTRIBUTE1 in VARCHAR2
   ,p_new_AAT_ATTRIBUTE1 in VARCHAR2
   ,p_old_AAT_ATTRIBUTE10 in VARCHAR2
   ,p_new_AAT_ATTRIBUTE10 in VARCHAR2
   ,p_old_AAT_ATTRIBUTE11 in VARCHAR2
   ,p_new_AAT_ATTRIBUTE11 in VARCHAR2
   ,p_old_AAT_ATTRIBUTE12 in VARCHAR2
   ,p_new_AAT_ATTRIBUTE12 in VARCHAR2
   ,p_old_AAT_ATTRIBUTE13 in VARCHAR2
   ,p_new_AAT_ATTRIBUTE13 in VARCHAR2
   ,p_old_AAT_ATTRIBUTE14 in VARCHAR2
   ,p_new_AAT_ATTRIBUTE14 in VARCHAR2
   ,p_old_AAT_ATTRIBUTE15 in VARCHAR2
   ,p_new_AAT_ATTRIBUTE15 in VARCHAR2
   ,p_old_AAT_ATTRIBUTE16 in VARCHAR2
   ,p_new_AAT_ATTRIBUTE16 in VARCHAR2
   ,p_old_AAT_ATTRIBUTE17 in VARCHAR2
   ,p_new_AAT_ATTRIBUTE17 in VARCHAR2
   ,p_old_AAT_ATTRIBUTE18 in VARCHAR2
   ,p_new_AAT_ATTRIBUTE18 in VARCHAR2
   ,p_old_AAT_ATTRIBUTE19 in VARCHAR2
   ,p_new_AAT_ATTRIBUTE19 in VARCHAR2
   ,p_old_AAT_ATTRIBUTE2 in VARCHAR2
   ,p_new_AAT_ATTRIBUTE2 in VARCHAR2
   ,p_old_AAT_ATTRIBUTE20 in VARCHAR2
   ,p_new_AAT_ATTRIBUTE20 in VARCHAR2
   ,p_old_AAT_ATTRIBUTE3 in VARCHAR2
   ,p_new_AAT_ATTRIBUTE3 in VARCHAR2
   ,p_old_AAT_ATTRIBUTE4 in VARCHAR2
   ,p_new_AAT_ATTRIBUTE4 in VARCHAR2
   ,p_old_AAT_ATTRIBUTE5 in VARCHAR2
   ,p_new_AAT_ATTRIBUTE5 in VARCHAR2
   ,p_old_AAT_ATTRIBUTE6 in VARCHAR2
   ,p_new_AAT_ATTRIBUTE6 in VARCHAR2
   ,p_old_AAT_ATTRIBUTE7 in VARCHAR2
   ,p_new_AAT_ATTRIBUTE7 in VARCHAR2
   ,p_old_AAT_ATTRIBUTE8 in VARCHAR2
   ,p_new_AAT_ATTRIBUTE8 in VARCHAR2
   ,p_old_AAT_ATTRIBUTE9 in VARCHAR2
   ,p_new_AAT_ATTRIBUTE9 in VARCHAR2
   ,p_old_AAT_ATTRIBUTE_CATEGORY in VARCHAR2
   ,p_new_AAT_ATTRIBUTE_CATEGORY in VARCHAR2
   ,p_old_AAT_INFORMATION1 in VARCHAR2
   ,p_new_AAT_INFORMATION1 in VARCHAR2
   ,p_old_AAT_INFORMATION10 in VARCHAR2
   ,p_new_AAT_INFORMATION10 in VARCHAR2
   ,p_old_AAT_INFORMATION11 in VARCHAR2
   ,p_new_AAT_INFORMATION11 in VARCHAR2
   ,p_old_AAT_INFORMATION12 in VARCHAR2
   ,p_new_AAT_INFORMATION12 in VARCHAR2
   ,p_old_AAT_INFORMATION13 in VARCHAR2
   ,p_new_AAT_INFORMATION13 in VARCHAR2
   ,p_old_AAT_INFORMATION14 in VARCHAR2
   ,p_new_AAT_INFORMATION14 in VARCHAR2
   ,p_old_AAT_INFORMATION15 in VARCHAR2
   ,p_new_AAT_INFORMATION15 in VARCHAR2
   ,p_old_AAT_INFORMATION16 in VARCHAR2
   ,p_new_AAT_INFORMATION16 in VARCHAR2
   ,p_old_AAT_INFORMATION17 in VARCHAR2
   ,p_new_AAT_INFORMATION17 in VARCHAR2
   ,p_old_AAT_INFORMATION18 in VARCHAR2
   ,p_new_AAT_INFORMATION18 in VARCHAR2
   ,p_old_AAT_INFORMATION19 in VARCHAR2
   ,p_new_AAT_INFORMATION19 in VARCHAR2
   ,p_old_AAT_INFORMATION2 in VARCHAR2
   ,p_new_AAT_INFORMATION2 in VARCHAR2
   ,p_old_AAT_INFORMATION20 in VARCHAR2
   ,p_new_AAT_INFORMATION20 in VARCHAR2
   ,p_old_AAT_INFORMATION3 in VARCHAR2
   ,p_new_AAT_INFORMATION3 in VARCHAR2
   ,p_old_AAT_INFORMATION4 in VARCHAR2
   ,p_new_AAT_INFORMATION4 in VARCHAR2
   ,p_old_AAT_INFORMATION5 in VARCHAR2
   ,p_new_AAT_INFORMATION5 in VARCHAR2
   ,p_old_AAT_INFORMATION6 in VARCHAR2
   ,p_new_AAT_INFORMATION6 in VARCHAR2
   ,p_old_AAT_INFORMATION7 in VARCHAR2
   ,p_new_AAT_INFORMATION7 in VARCHAR2
   ,p_old_AAT_INFORMATION8 in VARCHAR2
   ,p_new_AAT_INFORMATION8 in VARCHAR2
   ,p_old_AAT_INFORMATION9 in VARCHAR2
   ,p_new_AAT_INFORMATION9 in VARCHAR2
   ,p_old_AAT_INFORMATION_CATEGORY in VARCHAR2
   ,p_new_AAT_INFORMATION_CATEGORY in VARCHAR2
   ,p_old_ASSIGNMENT_ATTRIBUTE_ID in NUMBER
   ,p_new_ASSIGNMENT_ATTRIBUTE_ID in NUMBER
   ,p_old_ASSIGNMENT_ID in NUMBER
   ,p_new_ASSIGNMENT_ID in NUMBER
   ,p_old_BUSINESS_GROUP_ID in NUMBER
   ,p_new_BUSINESS_GROUP_ID in NUMBER
   ,p_old_COMPANY_CAR_CALC_METHOD in VARCHAR2
   ,p_new_COMPANY_CAR_CALC_METHOD in VARCHAR2
   ,p_old_COMPANY_CAR_RATES_TABLE_ in NUMBER
   ,p_new_COMPANY_CAR_RATES_TABLE_ in NUMBER
   ,p_old_COMPANY_CAR_SECONDARY_TA in NUMBER
   ,p_new_COMPANY_CAR_SECONDARY_TA in NUMBER
   ,p_old_CONTRACT_TYPE in VARCHAR2
   ,p_new_CONTRACT_TYPE in VARCHAR2
   ,p_old_PRIMARY_CAPITAL_CONTRIBU in NUMBER
   ,p_new_PRIMARY_CAPITAL_CONTRIBU in NUMBER
   ,p_old_PRIMARY_CAR_FUEL_BENEFIT in VARCHAR2
   ,p_new_PRIMARY_CAR_FUEL_BENEFIT in VARCHAR2
   ,p_old_PRIMARY_CLASS_1A in VARCHAR2
   ,p_new_PRIMARY_CLASS_1A in VARCHAR2
   ,p_old_PRIMARY_COMPANY_CAR in NUMBER
   ,p_new_PRIMARY_COMPANY_CAR in NUMBER
   ,p_old_PRIMARY_PRIVATE_CONTRIBU in NUMBER
   ,p_new_PRIMARY_PRIVATE_CONTRIBU in NUMBER
   ,p_old_PRIVATE_CAR in NUMBER
   ,p_new_PRIVATE_CAR in NUMBER
   ,p_old_PRIVATE_CAR_CALC_METHOD in VARCHAR2
   ,p_new_PRIVATE_CAR_CALC_METHOD in VARCHAR2
   ,p_old_PRIVATE_CAR_ESSENTIAL_TA in NUMBER
   ,p_new_PRIVATE_CAR_ESSENTIAL_TA in NUMBER
   ,p_old_PRIVATE_CAR_RATES_TABLE_ in NUMBER
   ,p_new_PRIVATE_CAR_RATES_TABLE_ in NUMBER
   ,p_old_SECONDARY_CAPITAL_CONTRI in NUMBER
   ,p_new_SECONDARY_CAPITAL_CONTRI in NUMBER
   ,p_old_SECONDARY_CAR_FUEL_BENEF in VARCHAR2
   ,p_new_SECONDARY_CAR_FUEL_BENEF in VARCHAR2
   ,p_old_SECONDARY_CLASS_1A in VARCHAR2
   ,p_new_SECONDARY_CLASS_1A in VARCHAR2
   ,p_old_SECONDARY_COMPANY_CAR in NUMBER
   ,p_new_SECONDARY_COMPANY_CAR in NUMBER
   ,p_old_SECONDARY_PRIVATE_CONTRI in NUMBER
   ,p_new_SECONDARY_PRIVATE_CONTRI in NUMBER
   ,p_old_START_DAY in VARCHAR2
   ,p_new_START_DAY in VARCHAR2
   ,p_old_TP_ELECTED_PENSION in VARCHAR2
   ,p_new_TP_ELECTED_PENSION in VARCHAR2
   ,p_old_TP_FAST_TRACK in VARCHAR2
   ,p_new_TP_FAST_TRACK in VARCHAR2
   ,p_old_TP_IS_TEACHER in VARCHAR2
   ,p_new_TP_IS_TEACHER in VARCHAR2
   ,p_old_TP_SAFEGUARDED_GRADE in VARCHAR2
   ,p_new_TP_SAFEGUARDED_GRADE in VARCHAR2
   ,p_old_TP_SAFEGUARDED_RATE_ID in NUMBER
   ,p_new_TP_SAFEGUARDED_RATE_ID in NUMBER
   ,p_old_TP_SAFEGUARDED_RATE_TYPE in VARCHAR2
   ,p_new_TP_SAFEGUARDED_RATE_TYPE in VARCHAR2
   ,p_old_TP_SAFEGUARDED_SPINAL_PO in NUMBER
   ,p_new_TP_SAFEGUARDED_SPINAL_PO in NUMBER
   ,p_old_WORK_PATTERN in VARCHAR2
   ,p_new_WORK_PATTERN in VARCHAR2
   ,p_old_EFFECTIVE_END_DATE in DATE
   ,p_new_EFFECTIVE_END_DATE in DATE
   ,p_old_EFFECTIVE_START_DATE in DATE
   ,p_new_EFFECTIVE_START_DATE in DATE
   ,p_old_LGPS_PROCESS_FLAG in VARCHAR2
   ,p_new_LGPS_PROCESS_FLAG in VARCHAR2
   ,p_old_LGPS_EXCLUSION_TYPE in VARCHAR2
   ,p_new_LGPS_EXCLUSION_TYPE in VARCHAR2
   ,p_old_LGPS_PENSIONABLE_PAY in VARCHAR2
   ,p_new_LGPS_PENSIONABLE_PAY in VARCHAR2
   ,p_old_LGPS_TRANS_ARRANG_FLAG in VARCHAR2
   ,p_new_LGPS_TRANS_ARRANG_FLAG in VARCHAR2
   ,p_old_LGPS_MEMBERSHIP_NUMBER in VARCHAR2
   ,p_new_LGPS_MEMBERSHIP_NUMBER in VARCHAR2
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
     if (p_old_EFFECTIVE_END_DATE = p_new_EFFECTIVE_END_DATE
        and  p_old_EFFECTIVE_START_DATE = p_new_EFFECTIVE_START_DATE) then
   --
       pay_continuous_calc.event_update(p_business_group_id
       				    ,p_legislation_code
       				    ,'PQP_ASSIGNMENT_ATTRIBUTES_F'
       				    ,'AAT_ATTRIBUTE1'
       				    ,p_old_AAT_ATTRIBUTE1
       				    ,p_new_AAT_ATTRIBUTE1
       				    ,p_effective_date
       				    );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_ATTRIBUTE10',
                                        p_old_AAT_ATTRIBUTE10,
                                        p_new_AAT_ATTRIBUTE10,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_ATTRIBUTE11',
                                        p_old_AAT_ATTRIBUTE11,
                                        p_new_AAT_ATTRIBUTE11,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_ATTRIBUTE12',
                                        p_old_AAT_ATTRIBUTE12,
                                        p_new_AAT_ATTRIBUTE12,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_ATTRIBUTE13',
                                        p_old_AAT_ATTRIBUTE13,
                                        p_new_AAT_ATTRIBUTE13,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_ATTRIBUTE14',
                                        p_old_AAT_ATTRIBUTE14,
                                        p_new_AAT_ATTRIBUTE14,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_ATTRIBUTE15',
                                        p_old_AAT_ATTRIBUTE15,
                                        p_new_AAT_ATTRIBUTE15,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_ATTRIBUTE16',
                                        p_old_AAT_ATTRIBUTE16,
                                        p_new_AAT_ATTRIBUTE16,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_ATTRIBUTE17',
                                        p_old_AAT_ATTRIBUTE17,
                                        p_new_AAT_ATTRIBUTE17,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_ATTRIBUTE18',
                                        p_old_AAT_ATTRIBUTE18,
                                        p_new_AAT_ATTRIBUTE18,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_ATTRIBUTE19',
                                        p_old_AAT_ATTRIBUTE19,
                                        p_new_AAT_ATTRIBUTE19,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_ATTRIBUTE2',
                                        p_old_AAT_ATTRIBUTE2,
                                        p_new_AAT_ATTRIBUTE2,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_ATTRIBUTE20',
                                        p_old_AAT_ATTRIBUTE20,
                                        p_new_AAT_ATTRIBUTE20,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_ATTRIBUTE3',
                                        p_old_AAT_ATTRIBUTE3,
                                        p_new_AAT_ATTRIBUTE3,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_ATTRIBUTE4',
                                        p_old_AAT_ATTRIBUTE4,
                                        p_new_AAT_ATTRIBUTE4,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_ATTRIBUTE5',
                                        p_old_AAT_ATTRIBUTE5,
                                        p_new_AAT_ATTRIBUTE5,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_ATTRIBUTE6',
                                        p_old_AAT_ATTRIBUTE6,
                                        p_new_AAT_ATTRIBUTE6,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_ATTRIBUTE7',
                                        p_old_AAT_ATTRIBUTE7,
                                        p_new_AAT_ATTRIBUTE7,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_ATTRIBUTE8',
                                        p_old_AAT_ATTRIBUTE8,
                                        p_new_AAT_ATTRIBUTE8,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_ATTRIBUTE9',
                                        p_old_AAT_ATTRIBUTE9,
                                        p_new_AAT_ATTRIBUTE9,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_ATTRIBUTE_CATEGORY',
                                        p_old_AAT_ATTRIBUTE_CATEGORY,
                                        p_new_AAT_ATTRIBUTE_CATEGORY,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_INFORMATION1',
                                        p_old_AAT_INFORMATION1,
                                        p_new_AAT_INFORMATION1,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_INFORMATION10',
                                        p_old_AAT_INFORMATION10,
                                        p_new_AAT_INFORMATION10,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_INFORMATION11',
                                        p_old_AAT_INFORMATION11,
                                        p_new_AAT_INFORMATION11,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_INFORMATION12',
                                        p_old_AAT_INFORMATION12,
                                        p_new_AAT_INFORMATION12,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_INFORMATION13',
                                        p_old_AAT_INFORMATION13,
                                        p_new_AAT_INFORMATION13,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_INFORMATION14',
                                        p_old_AAT_INFORMATION14,
                                        p_new_AAT_INFORMATION14,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_INFORMATION15',
                                        p_old_AAT_INFORMATION15,
                                        p_new_AAT_INFORMATION15,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_INFORMATION16',
                                        p_old_AAT_INFORMATION16,
                                        p_new_AAT_INFORMATION16,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_INFORMATION17',
                                        p_old_AAT_INFORMATION17,
                                        p_new_AAT_INFORMATION17,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_INFORMATION18',
                                        p_old_AAT_INFORMATION18,
                                        p_new_AAT_INFORMATION18,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_INFORMATION19',
                                        p_old_AAT_INFORMATION19,
                                        p_new_AAT_INFORMATION19,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_INFORMATION2',
                                        p_old_AAT_INFORMATION2,
                                        p_new_AAT_INFORMATION2,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_INFORMATION20',
                                        p_old_AAT_INFORMATION20,
                                        p_new_AAT_INFORMATION20,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_INFORMATION3',
                                        p_old_AAT_INFORMATION3,
                                        p_new_AAT_INFORMATION3,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_INFORMATION4',
                                        p_old_AAT_INFORMATION4,
                                        p_new_AAT_INFORMATION4,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_INFORMATION5',
                                        p_old_AAT_INFORMATION5,
                                        p_new_AAT_INFORMATION5,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_INFORMATION6',
                                        p_old_AAT_INFORMATION6,
                                        p_new_AAT_INFORMATION6,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_INFORMATION7',
                                        p_old_AAT_INFORMATION7,
                                        p_new_AAT_INFORMATION7,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_INFORMATION8',
                                        p_old_AAT_INFORMATION8,
                                        p_new_AAT_INFORMATION8,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_INFORMATION9',
                                        p_old_AAT_INFORMATION9,
                                        p_new_AAT_INFORMATION9,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'AAT_INFORMATION_CATEGORY',
                                        p_old_AAT_INFORMATION_CATEGORY,
                                        p_new_AAT_INFORMATION_CATEGORY,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'ASSIGNMENT_ATTRIBUTE_ID',
                                        p_old_ASSIGNMENT_ATTRIBUTE_ID,
                                        p_new_ASSIGNMENT_ATTRIBUTE_ID,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'ASSIGNMENT_ID',
                                        p_old_ASSIGNMENT_ID,
                                        p_new_ASSIGNMENT_ID,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'BUSINESS_GROUP_ID',
                                        p_old_BUSINESS_GROUP_ID,
                                        p_new_BUSINESS_GROUP_ID,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'COMPANY_CAR_CALC_METHOD',
                                        p_old_COMPANY_CAR_CALC_METHOD,
                                        p_new_COMPANY_CAR_CALC_METHOD,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'COMPANY_CAR_RATES_TABLE_ID',
                                        p_old_COMPANY_CAR_RATES_TABLE_,
                                        p_new_COMPANY_CAR_RATES_TABLE_,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'COMPANY_CAR_SECONDARY_TABLE_ID',
                                        p_old_COMPANY_CAR_SECONDARY_TA,
                                        p_new_COMPANY_CAR_SECONDARY_TA,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'CONTRACT_TYPE',
                                        p_old_CONTRACT_TYPE,
                                        p_new_CONTRACT_TYPE,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'PRIMARY_CAPITAL_CONTRIBUTION',
                                        p_old_PRIMARY_CAPITAL_CONTRIBU,
                                        p_new_PRIMARY_CAPITAL_CONTRIBU,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'PRIMARY_CAR_FUEL_BENEFIT',
                                        p_old_PRIMARY_CAR_FUEL_BENEFIT,
                                        p_new_PRIMARY_CAR_FUEL_BENEFIT,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'PRIMARY_CLASS_1A',
                                        p_old_PRIMARY_CLASS_1A,
                                        p_new_PRIMARY_CLASS_1A,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'PRIMARY_COMPANY_CAR',
                                        p_old_PRIMARY_COMPANY_CAR,
                                        p_new_PRIMARY_COMPANY_CAR,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'PRIMARY_PRIVATE_CONTRIBUTION',
                                        p_old_PRIMARY_PRIVATE_CONTRIBU,
                                        p_new_PRIMARY_PRIVATE_CONTRIBU,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'PRIVATE_CAR',
                                        p_old_PRIVATE_CAR,
                                        p_new_PRIVATE_CAR,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'PRIVATE_CAR_CALC_METHOD',
                                        p_old_PRIVATE_CAR_CALC_METHOD,
                                        p_new_PRIVATE_CAR_CALC_METHOD,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'PRIVATE_CAR_ESSENTIAL_TABLE_ID',
                                        p_old_PRIVATE_CAR_ESSENTIAL_TA,
                                        p_new_PRIVATE_CAR_ESSENTIAL_TA,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'PRIVATE_CAR_RATES_TABLE_ID',
                                        p_old_PRIVATE_CAR_RATES_TABLE_,
                                        p_new_PRIVATE_CAR_RATES_TABLE_,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'SECONDARY_CAPITAL_CONTRIBUTION',
                                        p_old_SECONDARY_CAPITAL_CONTRI,
                                        p_new_SECONDARY_CAPITAL_CONTRI,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'SECONDARY_CAR_FUEL_BENEFIT',
                                        p_old_SECONDARY_CAR_FUEL_BENEF,
                                        p_new_SECONDARY_CAR_FUEL_BENEF,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'SECONDARY_CLASS_1A',
                                        p_old_SECONDARY_CLASS_1A,
                                        p_new_SECONDARY_CLASS_1A,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'SECONDARY_COMPANY_CAR',
                                        p_old_SECONDARY_COMPANY_CAR,
                                        p_new_SECONDARY_COMPANY_CAR,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'SECONDARY_PRIVATE_CONTRIBUTION',
                                        p_old_SECONDARY_PRIVATE_CONTRI,
                                        p_new_SECONDARY_PRIVATE_CONTRI,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'START_DAY',
                                        p_old_START_DAY,
                                        p_new_START_DAY,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'TP_ELECTED_PENSION',
                                        p_old_TP_ELECTED_PENSION,
                                        p_new_TP_ELECTED_PENSION,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'TP_FAST_TRACK',
                                        p_old_TP_FAST_TRACK,
                                        p_new_TP_FAST_TRACK,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'TP_IS_TEACHER',
                                        p_old_TP_IS_TEACHER,
                                        p_new_TP_IS_TEACHER,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'TP_SAFEGUARDED_GRADE',
                                        p_old_TP_SAFEGUARDED_GRADE,
                                        p_new_TP_SAFEGUARDED_GRADE,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'TP_SAFEGUARDED_RATE_ID',
                                        p_old_TP_SAFEGUARDED_RATE_ID,
                                        p_new_TP_SAFEGUARDED_RATE_ID,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'TP_SAFEGUARDED_RATE_TYPE',
                                        p_old_TP_SAFEGUARDED_RATE_TYPE,
                                        p_new_TP_SAFEGUARDED_RATE_TYPE,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'TP_SAFEGUARDED_SPINAL_POINT_ID',
                                        p_old_TP_SAFEGUARDED_SPINAL_PO,
                                        p_new_TP_SAFEGUARDED_SPINAL_PO,
                                        p_effective_date
                                     );
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'WORK_PATTERN',
                                        p_old_WORK_PATTERN,
                                        p_new_WORK_PATTERN,
                                        p_effective_date
                                     );
   --
   /*    pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'WORK_PATTERN',
                                        p_old_WORK_PATTERN,
                                        p_new_WORK_PATTERN,
                                        p_effective_date
                                     );*/  -- This was written twice hence commented

	 pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'LGPS_PROCESS_FLAG',
                                        p_old_LGPS_PROCESS_FLAG,
                                        p_new_LGPS_PROCESS_FLAG,
                                        p_effective_date
                                     );
          pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'LGPS_EXCLUSION_TYPE',
                                        p_old_LGPS_EXCLUSION_TYPE,
                                        p_new_LGPS_EXCLUSION_TYPE,
                                        p_effective_date
                                     );

	 pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'LGPS_PENSIONABLE_PAY',
                                        p_old_LGPS_PENSIONABLE_PAY,
                                        p_new_LGPS_PENSIONABLE_PAY,
                                        p_effective_date
                                     );
        pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'LGPS_TRANS_ARRANG_FLAG',
                                        p_old_LGPS_TRANS_ARRANG_FLAG,
                                        p_new_LGPS_TRANS_ARRANG_FLAG,
                                        p_effective_date
                                     );
        pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                        'LGPS_MEMBERSHIP_NUMBER',
                                        p_old_LGPS_MEMBERSHIP_NUMBER,
                                        p_new_LGPS_MEMBERSHIP_NUMBER,
                                        p_effective_date
                                     );

     else
       /* OK it must be a date track change */
   --
       pay_continuous_calc.event_update(p_business_group_id,
                                        p_legislation_code,
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
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
                                        'PQP_ASSIGNMENT_ATTRIBUTES_F',
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
                                               p_surrogate_key         => p_new_assignment_attribute_id
                                              );
            end loop;
        end if;
        pay_continuous_calc.g_event_list.sz := 0;
      end;
   --
   END PQP_ASSIGNMENT_ATTRIBUTE_F_aru;

--
--
--
  PROCEDURE pqp_assignment_attribute_f_ari
  (p_business_group_id             IN      NUMBER
  ,p_legislation_code              IN      VARCHAR2
  ,p_effective_date                IN      DATE
  ,p_new_assignment_attribute_id   IN      NUMBER
  ,p_new_assignment_id             IN      NUMBER
  ,p_new_effective_end_date        IN      DATE
  ,p_new_effective_start_date      IN      DATE
  )
  IS
    l_process_api               BOOLEAN;
    l_process_event_id          NUMBER;
    l_object_version_number     NUMBER;
    l_proc_name                 VARCHAR2(61):=
      'pqp_gb_tp_extract_triggers.pqp_assignment_attribute_f_ari';
  BEGIN
--

  hr_utility.set_location(l_proc_name, 10);

  /* If the continuous calc is overriden then do nothing */
  IF (pay_continuous_calc.g_override_cc = TRUE) THEN
    RETURN;
  END IF;
--
  hr_utility.set_location(l_proc_name, 20);
--
  pay_continuous_calc.event_update
    (p_business_group_id
    ,p_legislation_code
    ,'PQP_ASSIGNMENT_ATTRIBUTES_F'
    ,NULL
    ,NULL
    ,NULL
    ,p_new_effective_start_date
    ,p_new_effective_start_date
    ,'I'
    );

   /* Now call the API for the affected assignments */
  DECLARE
    cnt                        NUMBER;
    l_process_event_id         NUMBER;
    l_object_version_number    NUMBER;
  BEGIN
    IF (pay_continuous_calc.g_event_list.sz <> 0) THEN
      FOR cnt IN 1..pay_continuous_calc.g_event_list.sz
      LOOP
        pay_ppe_api.create_process_event
          (p_assignment_id         => p_new_assignment_id
          ,p_effective_date        =>
             pay_continuous_calc.g_event_list.effective_date(cnt)
          ,p_change_type           =>
             pay_continuous_calc.g_event_list.change_type(cnt)
          ,p_status                => 'U'
          ,p_description           =>
             pay_continuous_calc.g_event_list.description(cnt)
          ,p_process_event_id      => l_process_event_id
          ,p_object_version_number => l_object_version_number
          ,p_event_update_id       =>
             pay_continuous_calc.g_event_list.event_update_id(cnt)
          ,p_surrogate_key         => p_new_assignment_attribute_id
          ,p_calculation_date      =>
             pay_continuous_calc.g_event_list.calc_date(cnt)
          ,p_business_group_id     => p_business_group_id
         );
       END LOOP;
    END IF;
    pay_continuous_calc.g_event_list.sz := 0;
  END;
    hr_utility.set_location(l_proc_name, 50);
  END pqp_assignment_attribute_f_ari;

--
--
--

 procedure pqp_assignment_attribute_f_ard(
                                         p_business_group_id in number,
                                         p_legislation_code in varchar2,
                                         p_old_assignment_attribute_id in number,
                                         p_old_effective_start_date in date,
                                         p_new_effective_start_date in date,
                                         p_old_effective_end_date in date,
                                         p_new_effective_end_date in date,
					 p_old_assignment_id in number
                                        )
is
    l_process_event_id number;
    l_object_version_number number;
    l_effective_date date;
    l_proc varchar2(240) := 'pqp_gb_tp_extract_triggers.pqp_assignment_attribute_f_ard';

  begin
  hr_utility.set_location(l_proc, 10);
  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;

    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PQP_ASSIGNMENT_ATTRIBUTES_F',
                                     null,
                                     null,
                                     null,
                                     p_old_effective_start_date,
                                     p_old_effective_start_date,
                                     'D'	--l_mode
                                    );

   /* Now call the API for the affected assignments */
   declare
     cnt number;
     l_process_event_id number;
     l_object_version_number number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
    hr_utility.trace('> With in Create Process Event:        ');
         for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                                            p_assignment_id         => p_old_assignment_id,
                                            p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
                                            p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
                                            p_status                => 'U',
                                            p_description           => pay_continuous_calc.g_event_list.description(cnt),
                                            p_process_event_id      => l_process_event_id,
                                            p_object_version_number => l_object_version_number,
                                            p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
                                            p_surrogate_key         => p_old_assignment_attribute_id,
                                            p_calculation_date      => pay_continuous_calc.g_event_list.calc_date(cnt),
                                            p_business_group_id     => p_business_group_id
                                           );


         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
    hr_utility.set_location(l_proc, 900);
END pqp_assignment_attribute_f_ard;

--
--
--
END pqp_gb_tp_extract_triggers;

/
