--------------------------------------------------------
--  DDL for Package Body IGW_PROP_QUESTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_QUESTIONS_PVT" AS
--$Header: igwvpqeb.pls 115.5 2002/11/15 00:44:01 ashkumar ship $

   ---------------------------------------------------------------------------

   G_PKG_NAME  VARCHAR2(30) := 'IGW_PROP_QUESTIONS_PVT';

   ---------------------------------------------------------------------------

   PROCEDURE Check_Lock
   (
      p_rowid                  IN VARCHAR2,
      p_record_version_number  IN NUMBER,
      x_return_status          OUT NOCOPY VARCHAR2
   ) IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Check_Lock';

      l_locked                 VARCHAR2(1);

   BEGIN

      /*
      **   Initialize
      */

      x_return_status := Fnd_Api.G_Ret_Sts_Success;

      IF p_rowid IS NOT NULL AND p_record_version_number IS NOT NULL THEN

         SELECT 'N'
         INTO   l_locked
         FROM   igw_prop_questions
         WHERE  rowid = p_rowid
         AND    record_version_number  = p_record_version_number;

      END IF;

   EXCEPTION

      WHEN no_data_found THEN

         x_return_status := Fnd_Api.G_Ret_Sts_Error;
         Fnd_Message.Set_Name('IGW','IGW_SS_RECORD_CHANGED');
         Fnd_Msg_Pub.Add;

      WHEN others THEN

         x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;

         Fnd_Msg_Pub.Add_Exc_Msg
         (
            p_pkg_name       => G_PKG_NAME,
            p_procedure_name => l_api_name
         );

         RAISE Fnd_Api.G_Exc_Unexpected_Error;

   END Check_Lock;

   ---------------------------------------------------------------------------

   PROCEDURE Explanation_Or_Date_Required
   (
      p_question_number IN VARCHAR2,
      p_answer          IN VARCHAR2,
      p_explanation     IN VARCHAR2,
      p_review_date     IN VARCHAR2,
      x_return_status   OUT NOCOPY VARCHAR2
   ) IS

      l_api_name      CONSTANT    VARCHAR2(30) := 'Explanation_Or_Date_Required';

      l_explanation_for_yes_flag  VARCHAR2(1);
      l_explanation_for_no_flag   VARCHAR2(1);
      l_date_for_yes_flag         VARCHAR2(1);
      l_date_for_no_flag          VARCHAR2(1);

   BEGIN

      SELECT
         explanation_for_yes_flag,
         explanation_for_no_flag,
         date_for_yes_flag,
         date_for_no_flag
      INTO
         l_explanation_for_yes_flag,
         l_explanation_for_no_flag,
         l_date_for_yes_flag,
         l_date_for_no_flag
      FROM
         igw_questions
      WHERE
         question_number = p_question_number;

      IF p_explanation IS NULL THEN

         IF (p_answer = '1' AND l_explanation_for_yes_flag = 'Y') OR
            (p_answer = '2' AND l_explanation_for_no_flag = 'Y') THEN

            x_return_status:= Fnd_Api.G_Ret_Sts_Error;
            Fnd_Message.Set_Name('IGW','IGW_EXPLANATION_REQUIRED');
            Fnd_Msg_Pub.Add;

         END IF;

      END IF;

      IF p_review_date IS NULL THEN

         IF (p_answer = '1' AND l_date_for_yes_flag = 'Y') OR
            (p_answer = '2' AND l_date_for_no_flag = 'Y') THEN

            x_return_status:= Fnd_Api.G_Ret_Sts_Error;
            Fnd_Message.Set_Name('IGW','IGW_DATE_REQUIRED');
            Fnd_Msg_Pub.Add;

         END IF;

      END IF;

   EXCEPTION

      WHEN no_data_found THEN

         x_return_status := Fnd_Api.G_Ret_Sts_Error;
         Fnd_Message.Set_Name('IGW','IGW_SS_QUESTION_INVALID');
         Fnd_Msg_Pub.Add;

      WHEN others THEN

         x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;

         Fnd_Msg_Pub.Add_Exc_Msg
         (
            p_pkg_name       => G_PKG_NAME,
            p_procedure_name => l_api_name
         );

         RAISE Fnd_Api.G_Exc_Unexpected_Error;

   END Explanation_Or_Date_Required;

   ---------------------------------------------------------------------------

   PROCEDURE Populate_Prop_Questions( p_proposal_id IN NUMBER ) IS
   BEGIN

      INSERT INTO igw_prop_questions
      (
         proposal_id,
         question_number,
         answer,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         record_version_number
      )
      SELECT
         p_proposal_id,
         question_number,
         '3',
         SYSDATE,
         Fnd_Global.User_Id,
         SYSDATE,
         Fnd_Global.User_Id,
         Fnd_Global.Login_Id,
         1
      FROM
         igw_questions
      WHERE
         applies_to = 'P' AND
         SYSDATE >= start_date_active AND
         (SYSDATE <= end_date_active OR end_date_active IS NULL) AND
         question_number NOT IN
            ( SELECT question_number
              FROM   igw_prop_questions
              WHERE  proposal_id = p_proposal_id );

      COMMIT;

   END Populate_Prop_Questions;

   ---------------------------------------------------------------------------

   PROCEDURE Update_Prop_Question
   (
      p_init_msg_list         IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only         IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                IN VARCHAR2   := Fnd_Api.G_False,
      p_rowid                 IN VARCHAR2,
      p_record_version_number IN NUMBER,
      p_proposal_id           IN NUMBER,
      p_proposal_number       IN VARCHAR2,
      p_question_number       IN VARCHAR2,
      p_answer                IN VARCHAR2,
      p_explanation           IN VARCHAR2,
      p_review_date           IN DATE,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2
   ) IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Update_Prop_Question';

      l_proposal_id            NUMBER       := p_proposal_id;

      l_return_status          VARCHAR2(1);

   BEGIN

      /*
      **   Establish Savepoint for Rollback
      */

      SAVEPOINT Update_Prop_Question_Pvt;


      /*
      **   Initialize
      */

      x_return_status := Fnd_Api.G_Ret_Sts_Success;

      IF Fnd_Api.To_Boolean(p_init_msg_list) THEN

         Fnd_Msg_Pub.Initialize;

      END IF;


      /*
      **   Get Ids from Values if Ids not passed
      */

      IF p_proposal_id IS NULL THEN

         Igw_Utils.Get_Proposal_Id
         (
            p_context_field    => 'PROPOSAL_ID',
            p_check_id_flag    => 'Y',
            p_proposal_number  => p_proposal_number,
            p_proposal_id      => p_proposal_id,
            x_proposal_id      => l_proposal_id,
            x_return_status    => l_return_status
         );

      END IF;

      IF Fnd_Msg_Pub.Count_Msg > 0 THEN

         RAISE Fnd_Api.G_Exc_Error;

      END IF;


      /*
      **   Check Modify Rights
      */
/*

      IF Igw_Security.Allow_Modify
         (
            p_function_name => 'PROPOSAL',
            p_proposal_id   => l_proposal_id,
            p_user_id       => Fnd_Global.User_Id
         )
         = 'N' THEN

         x_return_status := Fnd_Api.G_Ret_Sts_Error;
         Fnd_Message.Set_Name('IGW','IGW_SS_SEC_NO_MODIFY_RIGHTS');
         Fnd_Msg_Pub.Add;
         RAISE Fnd_Api.G_Exc_Error;

      END IF;

*/

      /*
      **   Check Lock before proceeding
      */

      Check_Lock
      (
         p_rowid                  => p_rowid,
         p_record_version_number  => p_record_version_number,
         x_return_status          => l_return_status
      );


      IF Fnd_Msg_Pub.Count_Msg > 0 THEN

         RAISE Fnd_Api.G_Exc_Error;

      END IF;

      Explanation_Or_Date_Required
      (
         p_question_number => p_question_number,
         p_answer          => p_answer,
         p_explanation     => p_explanation,
         p_review_date     => p_review_date,
         x_return_status   => x_return_status
      );

      IF Fnd_Msg_Pub.Count_Msg > 0 THEN

         RAISE Fnd_Api.G_Exc_Error;

      END IF;

      /*
      **   Discontinue processing if API invoked in validation mode
      */

      IF Fnd_Api.To_Boolean(p_validate_only) THEN

         RETURN;

      END IF;


      /*
      **   Invoke Table Handler to Update data
      */

      Igw_Prop_Questions_Tbh.Update_Row
      (
         p_rowid                 => p_rowid,
         p_record_version_number => p_record_version_number,
         p_proposal_id           => l_proposal_id,
         p_question_number       => p_question_number,
         p_answer                => p_answer,
         p_explanation           => p_explanation,
         p_review_date           => p_review_date,
         x_return_status         => l_return_status
      );


      /*
      **   Commit data if API invoked in commit mode
      */

      IF Fnd_Api.To_Boolean(p_commit) THEN

         COMMIT;

      END IF;


   EXCEPTION

      WHEN Fnd_Api.G_Exc_Error THEN

         ROLLBACK TO Update_Prop_Question_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN Fnd_Api.G_Exc_Unexpected_Error THEN

         ROLLBACK TO Update_Prop_Question_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN others THEN

         ROLLBACK TO Update_Prop_Question_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;

         Fnd_Msg_Pub.Add_Exc_Msg
         (
            p_pkg_name       => G_PKG_NAME,
            p_procedure_name => l_api_name
         );

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

   END Update_Prop_Question;

   ---------------------------------------------------------------------------

END Igw_Prop_Questions_Pvt;

/
