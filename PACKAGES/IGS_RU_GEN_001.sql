--------------------------------------------------------
--  DDL for Package IGS_RU_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RU_GEN_001" AUTHID CURRENT_USER AS
/* $Header: IGSRU01S.pls 120.1 2005/09/30 04:27:22 appldev ship $ */
  /*************************************************************
  Created By : nsinha
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  Navin           27-Aug-2001     Added a package variable p_evaluated_part
                                  as part of Bug# : 1899513.
  (reverse chronological order - newest change first)
  ***************************************************************/

Function Rulp_Val_Senna(
  p_rule_call_name IN VARCHAR2 DEFAULT NULL,
  p_person_id IN NUMBER DEFAULT NULL,
  p_course_cd IN VARCHAR2 DEFAULT NULL,
  p_course_version IN NUMBER DEFAULT NULL,
  p_unit_cd IN VARCHAR2 DEFAULT NULL,
  p_unit_version IN NUMBER DEFAULT NULL,
  p_cal_type IN VARCHAR2 DEFAULT NULL,
  p_ci_sequence_number IN NUMBER DEFAULT NULL,
  p_message OUT NOCOPY VARCHAR2 ,
  p_rule_number  NUMBER DEFAULT NULL,
  p_param_1  VARCHAR2 DEFAULT NULL,
  p_param_2  VARCHAR2 DEFAULT NULL,
  p_param_3  VARCHAR2 DEFAULT NULL,
  p_param_4  VARCHAR2 DEFAULT NULL,
  p_param_5  VARCHAR2 DEFAULT NULL,
  p_param_6  VARCHAR2 DEFAULT NULL,
  p_param_7  VARCHAR2 DEFAULT NULL,
  p_param_8  VARCHAR2 DEFAULT NULL,
  p_param_9  VARCHAR2 DEFAULT NULL,
  p_param_10  VARCHAR2 DEFAULT NULL,
  p_param_11  VARCHAR2 DEFAULT NULL,
  p_param_12  VARCHAR2 DEFAULT NULL,
  p_param_13  VARCHAR2 DEFAULT NULL,
  p_param_14  VARCHAR2 DEFAULT NULL,
  p_param_15  VARCHAR2 DEFAULT NULL,
  p_param_16  VARCHAR2 DEFAULT NULL,
  p_param_17  VARCHAR2 DEFAULT NULL,
  p_param_18  VARCHAR2 DEFAULT NULL,
  p_param_19  VARCHAR2 DEFAULT NULL,
  p_param_20  VARCHAR2 DEFAULT NULL,
  p_param_21  VARCHAR2 DEFAULT NULL,
  p_param_22  VARCHAR2 DEFAULT NULL,
  p_param_23  VARCHAR2 DEFAULT NULL,
  p_param_24  VARCHAR2 DEFAULT NULL,
  p_param_25  VARCHAR2 DEFAULT NULL,
  p_param_26  VARCHAR2 DEFAULT NULL,
  p_param_27  VARCHAR2 DEFAULT NULL,
  p_param_28  VARCHAR2 DEFAULT NULL,
  p_param_29  VARCHAR2 DEFAULT NULL,
  p_param_30  VARCHAR2 DEFAULT NULL,
  p_param_31  VARCHAR2 DEFAULT NULL,
  p_param_32  VARCHAR2 DEFAULT NULL,
  p_param_33  VARCHAR2 DEFAULT NULL,
  p_param_34  VARCHAR2 DEFAULT NULL,
  p_param_35  VARCHAR2 DEFAULT NULL,
  p_param_36  VARCHAR2 DEFAULT NULL,
  p_param_37  VARCHAR2 DEFAULT NULL,
  p_param_38  VARCHAR2 DEFAULT NULL,
  p_param_39  VARCHAR2 DEFAULT NULL,
  p_param_40  VARCHAR2 DEFAULT NULL,
  p_param_41  VARCHAR2 DEFAULT NULL,
  p_param_42  VARCHAR2 DEFAULT NULL,
  p_param_43  VARCHAR2 DEFAULT NULL,
  p_param_44  VARCHAR2 DEFAULT NULL,
  p_param_45  VARCHAR2 DEFAULT NULL,
  p_param_46  VARCHAR2 DEFAULT NULL,
  p_param_47  VARCHAR2 DEFAULT NULL,
  p_param_48  VARCHAR2 DEFAULT NULL,
  p_param_49  VARCHAR2 DEFAULT NULL,
  p_param_50  VARCHAR2 DEFAULT NULL,
  p_param_51  VARCHAR2 DEFAULT NULL,
  p_param_52  VARCHAR2 DEFAULT NULL,
  p_param_53  VARCHAR2 DEFAULT NULL,
  p_param_54  VARCHAR2 DEFAULT NULL,
  p_param_55  VARCHAR2 DEFAULT NULL,
  p_param_56  VARCHAR2 DEFAULT NULL,
  p_param_57  VARCHAR2 DEFAULT NULL,
  p_param_58  VARCHAR2 DEFAULT NULL,
  p_param_59  VARCHAR2 DEFAULT NULL,
  p_param_60  VARCHAR2 DEFAULT NULL,
  p_param_61  VARCHAR2 DEFAULT NULL,
  p_param_62  VARCHAR2 DEFAULT NULL,
  p_param_63  VARCHAR2 DEFAULT NULL,
  p_param_64  VARCHAR2 DEFAULT NULL,
  p_param_65  VARCHAR2 DEFAULT NULL,
  p_param_66  VARCHAR2 DEFAULT NULL,
  p_param_67  VARCHAR2 DEFAULT NULL,
  p_param_68  VARCHAR2 DEFAULT NULL,
  p_param_69  VARCHAR2 DEFAULT NULL,
  p_param_70  VARCHAR2 DEFAULT NULL,
  p_param_71  VARCHAR2 DEFAULT NULL,
  p_param_72  VARCHAR2 DEFAULT NULL,
  p_param_73  VARCHAR2 DEFAULT NULL,
  p_param_74  VARCHAR2 DEFAULT NULL,
  p_param_75  VARCHAR2 DEFAULT NULL,
  p_param_76  VARCHAR2 DEFAULT NULL,
  p_param_77  VARCHAR2 DEFAULT NULL,
  p_param_78  VARCHAR2 DEFAULT NULL,
  p_param_79  VARCHAR2 DEFAULT NULL,
  p_param_80  VARCHAR2 DEFAULT NULL,
  p_param_81  VARCHAR2 DEFAULT NULL,
  p_param_82  VARCHAR2 DEFAULT NULL,
  p_param_83  VARCHAR2 DEFAULT NULL,
  p_param_84  VARCHAR2 DEFAULT NULL,
  p_param_85  VARCHAR2 DEFAULT NULL,
  p_param_86  VARCHAR2 DEFAULT NULL,
  p_param_87  VARCHAR2 DEFAULT NULL,
  p_param_88  VARCHAR2 DEFAULT NULL,
  p_param_89  VARCHAR2 DEFAULT NULL,
  p_param_90  VARCHAR2 DEFAULT NULL,
  p_param_91  VARCHAR2 DEFAULT NULL,
  p_param_92  VARCHAR2 DEFAULT NULL,
  p_param_93  VARCHAR2 DEFAULT NULL,
  p_param_94  VARCHAR2 DEFAULT NULL,
  p_param_95  VARCHAR2 DEFAULT NULL,
  p_param_96  VARCHAR2 DEFAULT NULL,
  p_param_97  VARCHAR2 DEFAULT NULL,
  p_param_98  VARCHAR2 DEFAULT NULL,
  p_param_99  VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

-- Package variables
p_evaluated_part   VARCHAR2(2000);

END IGS_RU_GEN_001;

 

/
