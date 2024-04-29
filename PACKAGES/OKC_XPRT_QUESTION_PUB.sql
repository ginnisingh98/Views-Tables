--------------------------------------------------------
--  DDL for Package OKC_XPRT_QUESTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_XPRT_QUESTION_PUB" AUTHID CURRENT_USER AS
/* $Header: OKCPXIQS.pls 120.0.12010000.2 2011/03/10 18:06:06 harchand noship $ */

   /*
    *    *** SCOPE OF THIS PUBLIC API ***
    *  Supports Creation of/Updation to Questions/Constants.
    *  Does not support Deletion of Questions/Constants.
    *
    */

   /*

 **** Business Rules for Questions:
 => You must provide the intent for the question.
 => A question name must be unique for a given intent.
 => You can make changes to the existing questions.
    However, you cannot update Name,Intent, Response Type, and Value Set if the question is used in a rule.
    You can update  Description and Question Prompt even if the question is used in a rule.
    For the prompt changes to take effect on a business document, you must run the Contract Expert:
    Synchronize Templates concurrent program.
 => You can use the Disable check box to prevent the question from being used in a new rule.
    This will not impact existing rules that use this question.

 ***** Business Rules for Constants:
 => You must provide the intent for the constant, that is, Buy or Sell.
 => A constant name must be unique for a given intent.
 => The name and intent of a constant cannot be changed if the constant is used in a rule.
 => You can make changes to the
    name,description, intent, and value of the constant if the constant is not used in any rules.
    If the constant is included in a rule, you can change only its value and description.

 */

   /**
    * **************************
    * ***  Defaulting Rules  ***
    * **************************
    *
    *  During the creation of question/constant, If the user does not provide any values for the
    *  following fields, then the API will default the  values as below:
    *     DISABLED_FLAG            => 'N'
    *     QUESTION_SYNC_FLAG       => 'Y'  ( for Questions only)
    *     OBJECT_VERSION_NUMBER    => 1
    */

   /*
 *
  okc_exprt_questions_type stores information about questions and constants
  QUESTION_TYPE       VARCHAR2(1) Yes This indicates the question type.
                                      FK to FND lookup OKC_XPRT_QUESTION_TYPE.
                                      Possible values are Q and C. Q: Question, C: Constant.
  QUESTION_INTENT     VARCHAR2(1) Yes Intent of Question or Constant. B: Buy, S: Sell.
  DISABLED_FLAG       VARCHAR2(1) Yes Indicates if the question or constant is disabled
  QUESTION_DATATYPE   VARCHAR2(1) Yes Indicates response datatype.
                                      FK to FND lookup OKC_XPRT_QUESTION_DATATYPE.
                                      B: Boolean, N: Numeric, L: List of values.
  VALUE_SET_NAME      VARCHAR2(60)    The value set corresponding to the question with response type of
                                      List of Values. FK to FND value set.
  DEFAULT_VALUE       NUMBER          Value for Constants. This is mandatory for defining constants.
  QUESTION_SYNC_FLAG  VARCHAR2(1)   Yes This will be used to indicate if a question needs to be synchronized with Oracle Confiugrator
  QUESTION_NAME       VARCHAR2(150) Yes User question name / Constant name
  LANGUAGE            VARCHAR2(4)   Yes Language in which the question or constant is created
  SOURCE_LANG         VARCHAR2(4)   Yes The base language from which the values are translated
  DESCRIPTION         VARCHAR2(2000)      Description of Question / Constant.
  PROMPT             VARCHAR2(450)     Question prompt that will be displayed to user in runtime UI.
                                        This is not applicable to constants.
 *
 */
   PROCEDURE create_question (
      p_xprt_question_rec   IN OUT NOCOPY   okc_xprt_question_pvt.xprt_qn_const_rec_type,
      p_commit              IN VARCHAR2 := fnd_api.g_false
   );

   PROCEDURE create_question (
      p_xprt_question_tbl   IN OUT NOCOPY   okc_xprt_question_pvt.xprt_qn_const_tbl_type,
      p_commit              IN              VARCHAR2 := fnd_api.g_false
   );

   PROCEDURE update_question (
      p_xprt_update_question_rec   IN OUT NOCOPY   okc_xprt_question_pvt.xprt_qn_const_rec_type,
      p_commit                     IN              VARCHAR2
            := fnd_api.g_false
   );

   PROCEDURE update_question (
      p_xprt_update_question_tbl   IN OUT NOCOPY   okc_xprt_question_pvt.xprt_qn_const_tbl_type,
      p_commit                     IN              VARCHAR2
            := fnd_api.g_false
   );


    PROCEDURE create_constant (
      p_xprt_constant_rec   IN OUT NOCOPY   okc_xprt_question_pvt.xprt_qn_const_rec_type,
      p_commit              IN VARCHAR2 := fnd_api.g_false
   );

   PROCEDURE create_constant (
      p_xprt_constant_tbl   IN OUT NOCOPY   okc_xprt_question_pvt.xprt_qn_const_tbl_type,
      p_commit              IN              VARCHAR2 := fnd_api.g_false
   );

   PROCEDURE update_constant (
      p_xprt_update_constant_rec   IN OUT NOCOPY   okc_xprt_question_pvt.xprt_qn_const_rec_type,
      p_commit                     IN              VARCHAR2
            := fnd_api.g_false
   );

   PROCEDURE update_constant (
      p_xprt_update_constant_tbl   IN OUT NOCOPY   okc_xprt_question_pvt.xprt_qn_const_tbl_type,
      p_commit                     IN              VARCHAR2
            := fnd_api.g_false
   );



END okc_xprt_question_pub;

/
