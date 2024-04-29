--------------------------------------------------------
--  DDL for Package Body IGW_PROP_SPECIAL_REVIEWS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_SPECIAL_REVIEWS_PVT" AS
--$Header: igwvrevb.pls 115.6 2002/11/15 00:45:41 ashkumar ship $

   ---------------------------------------------------------------------------

   G_PKG_NAME  VARCHAR2(30) := 'IGW_PROP_SPECIAL_REVIEWS_PVT';

   ---------------------------------------------------------------------------

   PROCEDURE Check_Ins_Upd_Dep_Data
   (
      p_approval_type_code IN VARCHAR2,
      p_protocol_number    IN VARCHAR2,
      p_approval_date      IN DATE,
      p_application_date   IN DATE,
      x_return_status OUT NOCOPY VARCHAR2
   ) IS

      l_api_name      CONSTANT      VARCHAR2(30) := 'Check_Update_Dependent_Data';

   BEGIN

      /*
      **   Initialize
      */

      x_return_status := Fnd_Api.G_Ret_Sts_Success;
/*

      IF p_rowid IS NULL THEN

         RETURN;

      END IF;
*/

      IF  p_approval_type_code='2' then
         IF (p_approval_date IS NULL) then
            x_return_status:= FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('IGW','IGW_PROP_REV_APPDATE_REQ');
         ELSE
             IF (p_protocol_number IS NULL) then
               x_return_status:=FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.SET_NAME('IGW','IGW_PROP_REV_PROTNO_REQ');
             ELSE
               return;
             END IF;
         END IF;

      ELSIF p_approval_type_code='1' then
           IF (p_application_date IS NULL) then
               x_return_status:= FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.SET_NAME('IGW','IGW_PROP_REV_APPLDATE_REQ');
           ELSE
               return;
           END IF;
      ELSE
           return;
      END IF;

   EXCEPTION

      WHEN others THEN

         x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;

         Fnd_Msg_Pub.Add_Exc_Msg
         (
            p_pkg_name       => G_PKG_NAME,
            p_procedure_name => l_api_name
         );

         RAISE Fnd_Api.G_Exc_Unexpected_Error;

   END Check_Ins_Upd_Dep_Data;

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
         FROM   igw_prop_special_reviews
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

   PROCEDURE Create_Prop_Special_Reviews
   (
      p_init_msg_list          IN VARCHAR2,
      p_validate_only          IN VARCHAR2,
      p_commit                 IN VARCHAR2,
      x_rowid                  OUT NOCOPY VARCHAR2,
      p_proposal_id            IN NUMBER,
      p_proposal_number        IN VARCHAR2,
      p_special_review_code    IN VARCHAR2,
      p_special_review_desc    IN VARCHAR2,
      p_special_review_type    IN VARCHAR2,
      p_special_review_type_desc IN VARCHAR2,
      p_approval_type_code       IN VARCHAR2,
      p_approval_type_desc       IN VARCHAR2,
      p_protocol_number          IN VARCHAR2,
      p_application_date         IN DATE,
      p_approval_date            IN DATE,
      p_comments                 IN VARCHAR2,
      x_return_status          OUT NOCOPY VARCHAR2,
      x_msg_count              OUT NOCOPY NUMBER,
      x_msg_data               OUT NOCOPY VARCHAR2
   ) IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Create_Prop_Special_Reviews';

      l_proposal_id            NUMBER       := p_proposal_id;
      l_special_review_code     VARCHAR2(30) := p_special_review_code;
      l_special_review_type    VARCHAR2(30) := p_special_review_type;
      l_approval_type_code    VARCHAR2(30)  := p_approval_type_code;
      l_return_status          VARCHAR2(1);

   BEGIN

      /*
      **   Establish Savepoint for Rollback
      */

      SAVEPOINT Create_Prop_Spl_Review_Pvt;


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

/*
      IF p_proposal_id IS NULL THEN

         Igw_Utils.Get_Proposal_Id
         (
            p_context_field    => 'PROPOSAL_ID',
            p_proposal_number  => p_proposal_number,
            x_proposal_id      => l_proposal_id,
            x_return_status    => l_return_status
         );

      END IF;

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
      IF p_special_review_code IS NULL THEN

         Igw_Utils.Get_Lookup_Code
         (
            p_context_field  => 'SPECIAL_REVIEW_CODE',
            p_lookup_type    => 'IGW_SPECIAL_REVIEWS',
            p_lookup_meaning => p_special_review_desc,
            x_lookup_code    => l_special_review_code,
            x_return_status  => l_return_status
         );

      END IF;


      IF p_special_review_type IS NULL THEN

         Igw_Utils.Get_Lookup_Code
         (
            p_context_field  => 'SPECIAL_REVIEW_TYPE',
            p_lookup_type    => 'IGW_SPECIAL_REVIEW_TYPES',
            p_lookup_meaning => p_special_review_type_desc,
            x_lookup_code    => l_special_review_type,
            x_return_status  => l_return_status
         );

      END IF;


      IF p_approval_type_code IS NULL THEN

         Igw_Utils.Get_Lookup_Code
         (
            p_context_field  => 'APPROVAL_TYPE_CODE',
            p_lookup_type    => 'IGW_REVIEW_APPROVAL_TYPES',
            p_lookup_meaning => p_approval_type_desc,
            x_lookup_code    => l_approval_type_code,
            x_return_status  => l_return_status
         );
      END IF;

*/
      /*
      **   Discontinue processing if any error has been encountered during
      **   the earlier stages
      */

      IF Fnd_Msg_Pub.Count_Msg > 0 THEN

         RAISE Fnd_Api.G_Exc_Error;

      END IF;

       Check_Ins_Upd_Dep_Data
      (
      p_approval_type_code => l_approval_type_code,
      p_protocol_number    => p_protocol_number,
      p_approval_date      =>  p_approval_date,
      p_application_date   => p_application_date,
      x_return_status      =>l_return_status
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
      **   Invoke Table Handler to insert data
      */


      Igw_Prop_Special_Reviews_Tbh.Insert_Row
      (
         x_rowid                  => x_rowid,
         p_proposal_id            => l_proposal_id,
         p_special_review_code    => l_special_review_code,
         p_special_review_type    => l_special_review_type,
         p_approval_type_code     => l_approval_type_code,
         p_protocol_number        => p_protocol_number,
         p_application_date       => p_application_date,
         p_approval_date          => p_approval_date,
         p_comments               => p_comments,
         x_return_status          => l_return_status
      );


      /*
      **   Commit data if API invoked in commit mode
      */

      IF Fnd_Api.To_Boolean(p_commit) THEN

         COMMIT;

      END IF;


   EXCEPTION

      WHEN Fnd_Api.G_Exc_Error THEN

         ROLLBACK TO Create_Prop_Spl_Review_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN Fnd_Api.G_Exc_Unexpected_Error THEN

         ROLLBACK TO Create_Prop_Spl_Review_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN others THEN

         ROLLBACK TO Create_Prop_Spl_Review_Pvt;

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

   END Create_Prop_Special_Reviews;

   ---------------------------------------------------------------------------

   PROCEDURE Update_Prop_Special_Reviews
   (
      p_init_msg_list            IN VARCHAR2,
      p_validate_only            IN VARCHAR2,
      p_commit                   IN VARCHAR2,
      p_rowid                    IN VARCHAR2,
      p_proposal_id              IN NUMBER,
      p_proposal_number          IN VARCHAR2,
      p_special_review_code      IN VARCHAR2,
      p_special_review_desc      IN VARCHAR2,
      p_special_review_type      IN VARCHAR2,
      p_special_review_type_desc IN VARCHAR2,
      p_approval_type_code       IN VARCHAR2,
      p_approval_type_desc       IN VARCHAR2,
      p_protocol_number          IN VARCHAR2,
      p_application_date         IN DATE,
      p_approval_date            IN DATE,
      p_comments                 IN VARCHAR2,
      p_record_version_number  IN NUMBER,
      x_return_status          OUT NOCOPY VARCHAR2,
      x_msg_count              OUT NOCOPY NUMBER,
      x_msg_data               OUT NOCOPY VARCHAR2
   ) IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Update_Prop_Special_Reviews';

      l_proposal_id            NUMBER       := p_proposal_id;
      l_special_review_code     VARCHAR2(30) := p_special_review_code;
      l_special_review_type    VARCHAR2(30) := p_special_review_type;
      l_approval_type_code    VARCHAR2(30)  := p_approval_type_code;

      l_return_status          VARCHAR2(1);

   BEGIN

      /*
      **   Establish Savepoint for Rollback
      */

      SAVEPOINT Update_Prop_Spl_Reviews_Pvt;


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
/*
      IF p_proposal_id IS NULL THEN

         Igw_Utils.Get_Proposal_Id
         (
            p_context_field    => 'PROPOSAL_ID',
            p_proposal_number  => p_proposal_number,
            x_proposal_id      => l_proposal_id,
            x_return_status    => l_return_status
         );

      END IF;


      IF Fnd_Msg_Pub.Count_Msg > 0 THEN

         RAISE Fnd_Api.G_Exc_Error;

      END IF;
*/

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

/*
      IF p_special_review_code IS NULL THEN

         Igw_Utils.Get_Lookup_Code
         (
            p_context_field  => 'SPECIAL_REVIEW_CODE',
            p_lookup_type    => 'IGW_SPECIAL_REVIEWS',
            p_lookup_meaning => p_special_review_desc,
            x_lookup_code    => l_special_review_code,
            x_return_status  => l_return_status
         );

      END IF;


      IF p_special_review_type IS NULL THEN

         Igw_Utils.Get_Lookup_Code
         (
            p_context_field  => 'SPECIAL_REVIEW_TYPE',
            p_lookup_type    => 'IGW_SPECIAL_REVIEW_TYPES',
            p_lookup_meaning => p_special_review_type_desc,
            x_lookup_code    => l_special_review_type,
            x_return_status  => l_return_status
         );

      END IF;


      IF p_approval_type_code IS NULL THEN

         Igw_Utils.Get_Lookup_Code
         (
            p_context_field  => 'APPROVAL_TYPE_CODE',
            p_lookup_type    => 'IGW_REVIEW_APPROVAL_TYPES',
            p_lookup_meaning => p_approval_type_desc,
            x_lookup_code    => l_approval_type_code,
            x_return_status  => l_return_status
         );
      END IF;
*/


      /*
      **   Discontinue processing if any error has been encountered during
      **   the earlier stages
      */

      IF Fnd_Msg_Pub.Count_Msg > 0 THEN

         RAISE Fnd_Api.G_Exc_Error;

      END IF;

       Check_Ins_Upd_Dep_Data
      (
      p_approval_type_code => l_approval_type_code,
      p_protocol_number    => p_protocol_number,
      p_approval_date      =>  p_approval_date,
      p_application_date   => p_application_date,
      x_return_status      =>l_return_status
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

      Igw_Prop_Special_Reviews_Tbh.Update_Row
      (
         p_rowid                  => p_rowid,
         p_proposal_id            => l_proposal_id,
         p_special_review_code    => l_special_review_code,
         p_special_review_type    => l_special_review_type,
         p_approval_type_code     => l_approval_type_code,
         p_protocol_number        => p_protocol_number,
         p_application_date       => p_application_date,
         p_approval_date          => p_approval_date,
         p_comments               => p_comments,
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

         ROLLBACK TO Update_Prop_Spl_Reviews_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN Fnd_Api.G_Exc_Unexpected_Error THEN

         ROLLBACK TO Update_Prop_Spl_Reviews_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN others THEN

         ROLLBACK TO Update_Prop_Spl_Reviews_Pvt;

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

   END Update_Prop_Special_Reviews;

   ---------------------------------------------------------------------------

   PROCEDURE Delete_Prop_Special_Reviews
   (
      p_init_msg_list          IN VARCHAR2,
      p_validate_only          IN VARCHAR2,
      p_commit                 IN VARCHAR2,
      p_rowid                  IN VARCHAR2,
      p_proposal_id            IN NUMBER,
      p_record_version_number  IN NUMBER,
      x_return_status          OUT NOCOPY VARCHAR2,
      x_msg_count              OUT NOCOPY NUMBER,
      x_msg_data               OUT NOCOPY VARCHAR2
   ) IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Delete_Prop_Person';

      l_return_status          VARCHAR2(1);

   BEGIN

      /*
      **   Establish Savepoint for Rollback
      */

      SAVEPOINT Delete_Prop_Spl_Reviews_Pvt;


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
     ** Check Lock before processing
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

      Igw_Prop_Special_Reviews_Tbh.Delete_Row
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

         ROLLBACK TO Delete_Prop_Spl_Reviews_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN Fnd_Api.G_Exc_Unexpected_Error THEN

         ROLLBACK TO Delete_Prop_Spl_Reviews_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN others THEN

         ROLLBACK TO Delete_Prop_Spl_Reviews_Pvt;

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

   END Delete_Prop_Special_Reviews;

   ---------------------------------------------------------------------------

END Igw_Prop_Special_Reviews_Pvt;

/
