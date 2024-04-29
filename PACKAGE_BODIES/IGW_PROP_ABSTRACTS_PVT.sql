--------------------------------------------------------
--  DDL for Package Body IGW_PROP_ABSTRACTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_ABSTRACTS_PVT" AS
--$Header: igwvabsb.pls 115.6 2002/11/14 18:50:52 vmedikon ship $

   ---------------------------------------------------------------------------

   G_PKG_NAME  VARCHAR2(30) := 'IGW_PROP_ABSTRACTS_PVT';

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
         FROM   igw_prop_abstracts
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

   PROCEDURE Populate_Prop_Abstracts( p_proposal_id IN NUMBER ) IS
   BEGIN

      INSERT INTO igw_prop_abstracts
      (
         proposal_id,
         abstract_type,
         abstract_type_code,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         record_version_number
      )
      SELECT
         p_proposal_id,
         lookup_type,
         lookup_code,
         null,
         null,
         SYSDATE,
         Fnd_Global.User_Id,
         Fnd_Global.Login_Id,
         1
      FROM
         fnd_lookups
      WHERE
         lookup_type in ('IGW_ABSTRACT_TYPES','IGW_RESOURCE_TYPES') AND
         (lookup_type,lookup_code) NOT IN
            ( SELECT abstract_type,
                     abstract_type_code
              FROM   igw_prop_abstracts
              WHERE  proposal_id = p_proposal_id );

      COMMIT;

   END Populate_Prop_Abstracts;

   ---------------------------------------------------------------------------

   PROCEDURE Update_Prop_Abstract
   (
      p_init_msg_list         IN VARCHAR2,
      p_validate_only         IN VARCHAR2,
      p_commit                IN VARCHAR2,
      p_rowid                 IN VARCHAR2,
      p_proposal_id           IN NUMBER,
      p_proposal_number       IN VARCHAR2,
      p_abstract_type         IN VARCHAR2,
      p_abstract_type_code    IN VARCHAR2,
      p_abstract_type_desc    IN VARCHAR2,
      p_abstract              IN VARCHAR2,
      p_attribute_category    IN VARCHAR2,
      p_attribute1            IN VARCHAR2,
      p_attribute2            IN VARCHAR2,
      p_attribute3            IN VARCHAR2,
      p_attribute4            IN VARCHAR2,
      p_attribute5            IN VARCHAR2,
      p_attribute6            IN VARCHAR2,
      p_attribute7            IN VARCHAR2,
      p_attribute8            IN VARCHAR2,
      p_attribute9            IN VARCHAR2,
      p_attribute10           IN VARCHAR2,
      p_attribute11           IN VARCHAR2,
      p_attribute12           IN VARCHAR2,
      p_attribute13           IN VARCHAR2,
      p_attribute14           IN VARCHAR2,
      p_attribute15           IN VARCHAR2,
      p_record_version_number IN NUMBER,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2
   ) IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Update_Prop_Abstract';

      l_proposal_id            NUMBER       := p_proposal_id;
      l_abstract_type_code     VARCHAR2(30) := p_abstract_type_code;

      l_return_status          VARCHAR2(1);

   BEGIN

      /*
      **   Establish Savepoint for Rollback
      */

      SAVEPOINT Update_Prop_Abstract_Pvt;


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
      IF Fnd_Msg_Pub.Count_Msg > 0 THEN

         RAISE Fnd_Api.G_Exc_Error;

      END IF;


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


      IF p_abstract_type_desc IS NULL THEN

         l_abstract_type_code := NULL;

      ELSE

         Igw_Utils.Get_Lookup_Code
         (
            p_context_field  => 'ABSTRACT_TYPE_CODE',
            p_check_id_flag  => 'Y',
            p_lookup_type    => p_abstract_type,
            p_lookup_meaning => p_abstract_type_desc,
            p_lookup_code    => p_abstract_type_code,
            x_lookup_code    => l_abstract_type_code,
            x_return_status  => l_return_status
         );

      END IF;


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
      **   Invoke Table Handler to Update data
      */

      Igw_Prop_Abstracts_Tbh.Update_Row
      (
         p_rowid                 => p_rowid,
         p_proposal_id           => l_proposal_id,
         p_abstract_type         => p_abstract_type,
         p_abstract_type_code    => l_abstract_type_code,
         p_abstract              => p_abstract,
         p_attribute_category    => p_attribute_category,
         p_attribute1            => p_attribute1,
         p_attribute2            => p_attribute2,
         p_attribute3            => p_attribute3,
         p_attribute4            => p_attribute4,
         p_attribute5            => p_attribute5,
         p_attribute6            => p_attribute6,
         p_attribute7            => p_attribute7,
         p_attribute8            => p_attribute8,
         p_attribute9            => p_attribute9,
         p_attribute10           => p_attribute10,
         p_attribute11           => p_attribute11,
         p_attribute12           => p_attribute12,
         p_attribute13           => p_attribute13,
         p_attribute14           => p_attribute14,
         p_attribute15           => p_attribute15,
         p_record_version_number => p_record_version_number,
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

         ROLLBACK TO Update_Prop_Abstract_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN Fnd_Api.G_Exc_Unexpected_Error THEN

         ROLLBACK TO Update_Prop_Abstract_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN others THEN

         ROLLBACK TO Update_Prop_Abstract_Pvt;

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

   END Update_Prop_Abstract;

   ---------------------------------------------------------------------------

END Igw_Prop_Abstracts_Pvt;

/
