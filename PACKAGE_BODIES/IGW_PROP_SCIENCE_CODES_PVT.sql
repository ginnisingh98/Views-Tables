--------------------------------------------------------
--  DDL for Package Body IGW_PROP_SCIENCE_CODES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_SCIENCE_CODES_PVT" AS
--$Header: igwvkeyb.pls 115.5 2002/11/15 00:45:05 ashkumar ship $

   ---------------------------------------------------------------------------

   G_PKG_NAME  VARCHAR2(30) := 'IGW_PROP_SCIENCE_CODES_PVT';

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
         FROM   igw_prop_science_codes
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

   PROCEDURE Validate_Science_Code
   (
      p_science_code  IN VARCHAR2,
      x_return_status OUT NOCOPY VARCHAR2
   ) IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Validate_Science_Code';

      l_valid         VARCHAR2(1) := 'N';

   BEGIN

      /*
      **   Initialize
      */

      x_return_status := Fnd_Api.G_Ret_Sts_Success;

      IF p_science_code IS NOT NULL THEN

         SELECT 'Y'
         INTO   l_valid
         FROM   igw_science_codes
         WHERE  science_code = p_science_code;

      END IF;

   EXCEPTION

      WHEN no_data_found THEN

         x_return_status := Fnd_Api.G_Ret_Sts_Error;
         Fnd_Message.Set_Name('IGW','IGW_SS_KEYWORD_INVALID');
         Fnd_Msg_Pub.Add;

      WHEN others THEN

         x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;

         Fnd_Msg_Pub.Add_Exc_Msg
         (
            p_pkg_name       => G_PKG_NAME,
            p_procedure_name => l_api_name
         );

         RAISE Fnd_Api.G_Exc_Unexpected_Error;

   END Validate_Science_Code;

   ---------------------------------------------------------------------------

   PROCEDURE Create_Prop_Science_Code
   (
      p_init_msg_list          IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only          IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                 IN VARCHAR2   := Fnd_Api.G_False,
      x_rowid                  OUT NOCOPY VARCHAR2,
      p_proposal_id            IN NUMBER,
      p_proposal_number        IN VARCHAR2,
      p_science_code           IN VARCHAR2,
      p_description            IN VARCHAR2,
      x_return_status          OUT NOCOPY VARCHAR2,
      x_msg_count              OUT NOCOPY NUMBER,
      x_msg_data               OUT NOCOPY VARCHAR2
   ) IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Create_Prop_Science_Code';

      l_proposal_id            NUMBER       := p_proposal_id;
      l_science_code           VARCHAR2(30) := p_science_code;

      l_count                  NUMBER;
      l_return_status          VARCHAR2(1);

   BEGIN

      /*
      **   Establish Savepoint for Rollback
      */

      SAVEPOINT Create_Prop_Science_Code_Pvt;


      /*
      **   Initialize
      */

      x_return_status := Fnd_Api.G_Ret_Sts_Success;

      IF Fnd_Api.To_Boolean(p_init_msg_list) THEN

         Fnd_Msg_Pub.Initialize;

      END IF;


      /*
      **   Get Ids from Values if Ids not passed. Check Mandatory columns
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

      IF p_description IS NULL THEN

         l_science_code := NULL;

      ELSE

         Igw_Utils.Get_Science_Code
         (
            p_check_id_flag => 'N',
            p_description   => p_description,
            p_science_code  => p_science_code,
            x_science_code  => l_science_code,
            x_return_status => l_return_status
         );

      END IF;

      /*
      **   Discontinue processing if any error has been encountered during
      **   the earlier stages
      */

      IF Fnd_Msg_Pub.Count_Msg > 0 THEN

         RAISE Fnd_Api.G_Exc_Error;

      END IF;


      SELECT count(1)
      INTO   l_count
      FROM   igw_prop_science_codes
      WHERE  proposal_id = l_proposal_id
      AND    science_code = l_science_code;

      IF l_count > 0 THEN

         x_return_status := Fnd_Api.G_Ret_Sts_Error;
         Fnd_Message.Set_Name('IGW','IGW_SS_KEYWORD_ALREADY_EXISTS');
         Fnd_Msg_Pub.Add;
         RAISE Fnd_Api.G_Exc_Error;

      END IF;



      /*
      **   Discontinue processing if API invoked in validation mode
      */

      IF Fnd_Api.To_Boolean(p_validate_only) THEN

         RETURN;

      END IF;


      /*
      **   Invoke Table Handler to insert data
      */

      Igw_Prop_Science_Codes_Tbh.Insert_Row
      (
         x_rowid         => x_rowid,
         p_proposal_id   => l_proposal_id,
         p_science_code  => l_science_code,
         x_return_status => l_return_status
      );


      /*
      **   Commit data if API invoked in commit mode
      */

      IF Fnd_Api.To_Boolean(p_commit) THEN

         COMMIT;

      END IF;


   EXCEPTION

      WHEN Fnd_Api.G_Exc_Error THEN

         ROLLBACK TO Create_Prop_Science_Code_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN Fnd_Api.G_Exc_Unexpected_Error THEN

         ROLLBACK TO Create_Prop_Science_Code_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN others THEN

         ROLLBACK TO Create_Prop_Science_Code_Pvt;

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

   END Create_Prop_Science_Code;

   ---------------------------------------------------------------------------

   PROCEDURE Update_Prop_Science_Code
   (
      p_init_msg_list          IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only          IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                 IN VARCHAR2   := Fnd_Api.G_False,
      p_rowid                  IN VARCHAR2,
      p_proposal_id            IN NUMBER,
      p_proposal_number        IN VARCHAR2,
      p_science_code           IN VARCHAR2,
      p_description            IN VARCHAR2,
      p_record_version_number  IN NUMBER,
      x_return_status          OUT NOCOPY VARCHAR2,
      x_msg_count              OUT NOCOPY NUMBER,
      x_msg_data               OUT NOCOPY VARCHAR2
   ) IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Update_Prop_Science_Code';

      l_proposal_id            NUMBER       := p_proposal_id;
      l_science_code           VARCHAR2(30) := p_science_code;

      l_count                  NUMBER;
      l_return_status          VARCHAR2(1);

   BEGIN

      /*
      **   Establish Savepoint for Rollback
      */

      SAVEPOINT Update_Prop_Science_Code_Pvt;


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


      /*
      **   Discontinue processing if any error has been encountered during
      **   the earlier stages
      */


      IF Fnd_Msg_Pub.Count_Msg > 0 THEN

         RAISE Fnd_Api.G_Exc_Error;

      END IF;


      IF p_description IS NULL THEN

         l_science_code := NULL;

      ELSE

         Igw_Utils.Get_Science_Code
         (
            p_check_id_flag => 'N',
            p_description   => p_description,
            p_science_code  => p_science_code,
            x_science_code  => l_science_code,
            x_return_status => l_return_status
         );

      END IF;


      /*
      **   Discontinue processing if any error has been encountered during
      **   the earlier stages
      */

      IF Fnd_Msg_Pub.Count_Msg > 0 THEN

         RAISE Fnd_Api.G_Exc_Error;

      END IF;

      SELECT count(1)
      INTO   l_count
      FROM   igw_prop_science_codes
      WHERE  rowid <> p_rowid
      AND    proposal_id = l_proposal_id
      AND    science_code = l_science_code;

      IF l_count > 0 THEN

         x_return_status := Fnd_Api.G_Ret_Sts_Error;
         Fnd_Message.Set_Name('IGW','IGW_SS_KEYWORD_ALREADY_EXISTS');
         Fnd_Msg_Pub.Add;
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

      Igw_Prop_Science_Codes_Tbh.Update_Row
      (
         p_rowid                 => p_rowid,
         p_proposal_id           => l_proposal_id,
         p_science_code          => l_science_code,
         p_record_version_number => p_record_version_number,
         x_return_status         => x_return_status
      );


      /*
      **   Commit data if API invoked in commit mode
      */

      IF Fnd_Api.To_Boolean(p_commit) THEN

         COMMIT;

      END IF;


   EXCEPTION

      WHEN Fnd_Api.G_Exc_Error THEN

         ROLLBACK TO Update_Prop_Science_Code_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN Fnd_Api.G_Exc_Unexpected_Error THEN

         ROLLBACK TO Update_Prop_Science_Code_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN others THEN

         ROLLBACK TO Update_Prop_Science_Code_Pvt;

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

   END Update_Prop_Science_Code;

   ---------------------------------------------------------------------------

   PROCEDURE Delete_Prop_Science_Code
   (
      p_init_msg_list          IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only          IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                 IN VARCHAR2   := Fnd_Api.G_False,
      p_rowid                  IN VARCHAR2,
      p_proposal_id            IN NUMBER,
      p_record_version_number  IN NUMBER,
      x_return_status          OUT NOCOPY VARCHAR2,
      x_msg_count              OUT NOCOPY NUMBER,
      x_msg_data               OUT NOCOPY VARCHAR2
   ) IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Delete_Prop_Science_Code';

      l_return_status          VARCHAR2(1);

   BEGIN

      /*
      **   Establish Savepoint for Rollback
      */

      SAVEPOINT Delete_Prop_Science_Code_Pvt;


      /*
      **   Initialize
      */

      x_return_status := Fnd_Api.G_Ret_Sts_Success;

      IF Fnd_Api.To_Boolean(p_init_msg_list) THEN

         Fnd_Msg_Pub.Initialize;

      END IF;

      /*
      **   Check Modify Rights
      */


/*
      IF Igw_Security.Allow_Modify
         (
            p_function_name => 'PROPOSAL',
            p_proposal_id   => p_proposal_id,
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

      /*
      **   Discontinue processing if any error has been encountered during
      **   the earlier stages
      */

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
      **   Invoke Table Handler to Delete data
      */

      Igw_Prop_Science_Codes_Tbh.Delete_Row
      (
         p_rowid                  => p_rowid,
         p_record_version_number  => p_record_version_number,
         x_return_status          => x_return_status
      );


      /*
      **   Commit data if API invoked in commit mode
      */

      IF Fnd_Api.To_Boolean(p_commit) THEN

         COMMIT;

      END IF;


   EXCEPTION

      WHEN Fnd_Api.G_Exc_Error THEN

         ROLLBACK TO Delete_Prop_Science_Code_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN Fnd_Api.G_Exc_Unexpected_Error THEN

         ROLLBACK TO Delete_Prop_Science_Code_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN others THEN

         ROLLBACK TO Delete_Prop_Science_Code_Pvt;

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

   END Delete_Prop_Science_Code;

   ---------------------------------------------------------------------------

END Igw_Prop_Science_Codes_Pvt;

/
