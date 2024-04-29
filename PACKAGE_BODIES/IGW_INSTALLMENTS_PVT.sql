--------------------------------------------------------
--  DDL for Package Body IGW_INSTALLMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_INSTALLMENTS_PVT" AS
--$Header: igwvinsb.pls 115.3 2002/11/19 23:46:21 ashkumar noship $

   ---------------------------------------------------------------------------

   G_PKG_NAME  VARCHAR2(30) := 'IGW_INSTALLMENTS_PVT';

   ---------------------------------------------------------------------------

   PROCEDURE Check_Lock
   (
      p_rowid                  IN VARCHAR2,
      p_record_version_number  IN NUMBER
   ) IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Check_Lock';

      l_locked                 VARCHAR2(1);

   BEGIN

      /*
      **   Initialize
      */

      IF p_rowid IS NOT NULL AND p_record_version_number IS NOT NULL THEN

         SELECT 'N'
         INTO   l_locked
         FROM   igw_installments
         WHERE  rowid = p_rowid;
         --AND    record_version_number  = p_record_version_number;

      END IF;

   EXCEPTION

      WHEN no_data_found THEN

         Fnd_Message.Set_Name('IGW','IGW_SS_RECORD_CHANGED');
         Fnd_Msg_Pub.Add;

      WHEN others THEN

         Fnd_Msg_Pub.Add_Exc_Msg
         (
            p_pkg_name       => G_PKG_NAME,
            p_procedure_name => l_api_name
         );

         RAISE Fnd_Api.G_Exc_Unexpected_Error;

   END Check_Lock;

   ---------------------------------------------------------------------------

   FUNCTION Get_Gms_Lookup_Code( p_lookup_type VARCHAR2, p_meaning VARCHAR2 )
   RETURN varchar2 IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Get_Gms_Lookup_Code';

      l_lookup_code   VARCHAR2(30);

   BEGIN

      IF p_meaning IS NOT NULL THEN

         SELECT lookup_code
         INTO   l_lookup_code
         FROM   gms_lookups
         WHERE  lookup_type = p_lookup_type
         AND    meaning = p_meaning;

      END IF;

      RETURN l_lookup_code;

   EXCEPTION

      WHEN no_data_found THEN

         IF p_lookup_type = 'INSTALLMENT_TYPE' THEN

            Fnd_Message.Set_Name('IGW','IGW_SS_INSTALL_TYPE_INVALID');

         END IF;

         Fnd_Msg_Pub.Add;

         RETURN null;

      WHEN others THEN

         Fnd_Msg_Pub.Add_Exc_Msg
         (
            p_pkg_name       => G_PKG_NAME,
            p_procedure_name => l_api_name||' : '||p_lookup_type
         );

         RAISE Fnd_Api.G_Exc_Unexpected_Error;

   END Get_Gms_Lookup_Code;

   ---------------------------------------------------------------------------

   PROCEDURE Create_Installment
   (
      p_init_msg_list           IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only           IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                  IN VARCHAR2   := Fnd_Api.G_False,
      x_rowid                   OUT NOCOPY VARCHAR2,
      x_proposal_installment_id OUT NOCOPY NUMBER,
      p_proposal_award_id       IN NUMBER,
      p_installment_id          IN NUMBER,
      p_installment_number      IN VARCHAR2,
      p_installment_type_desc   IN VARCHAR2,
      p_installment_type_code   IN VARCHAR2,
      p_issue_date              IN DATE,
      p_close_date              IN DATE,
      p_start_date              IN DATE,
      p_end_date                IN DATE,
      p_direct_cost             IN NUMBER,
      p_indirect_cost           IN NUMBER,
      p_billable_flag           IN VARCHAR2,
      p_description             IN VARCHAR2,
      x_return_status           OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER,
      x_msg_data                OUT NOCOPY VARCHAR2
   ) IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Create_Installment';

      l_installment_type_code  VARCHAR2(30);

      l_count                  NUMBER;
      l_return_status          VARCHAR2(1);

   BEGIN

      /*
      **   Establish Savepoint for Rollback
      */

      SAVEPOINT Create_Installment_Pvt;


      /*
      **   Initialize
      */

      x_return_status := Fnd_Api.G_Ret_Sts_Success;

      IF Fnd_Api.To_Boolean(p_init_msg_list) THEN

         Fnd_Msg_Pub.Initialize;

      END IF;


      l_installment_type_code := Get_Gms_Lookup_Code('INSTALLMENT_TYPE',p_installment_type_desc);

      IF p_start_date > p_end_date THEN

         Fnd_Message.Set_Name('GMS','GMS_INST_ENDATE_BEF_INS_STDATE');
         Fnd_Msg_Pub.Add;

      END IF;

      IF p_end_date > p_close_date THEN

         Fnd_Message.Set_Name('GMS','GMS_INS_CLOSEDATE_BEF_ENDDATE') ;
         Fnd_Msg_Pub.Add;

      END IF;


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

      Igw_Installments_Tbh.Insert_Row
      (
         x_rowid                   => x_rowid,
         x_proposal_installment_id => x_proposal_installment_id,
         p_proposal_award_id       => p_proposal_award_id,
         p_installment_id          => p_installment_id,
         p_installment_number      => p_installment_number,
         p_installment_type_code   => l_installment_type_code,
         p_issue_date              => p_issue_date,
         p_close_date              => p_close_date,
         p_start_date              => p_start_date,
         p_end_date                => p_end_date,
         p_direct_cost             => p_direct_cost,
         p_indirect_cost           => p_indirect_cost,
         p_billable_flag           => p_billable_flag,
         p_description             => p_description,
         x_return_status           => l_return_status
      );

      /*
      **   Commit data if API invoked in commit mode
      */

      IF Fnd_Api.To_Boolean(p_commit) THEN

         COMMIT;

      END IF;


   EXCEPTION

      WHEN Fnd_Api.G_Exc_Error THEN

         ROLLBACK TO Create_Installment_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN Fnd_Api.G_Exc_Unexpected_Error THEN

         ROLLBACK TO Create_Installment_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN others THEN

         ROLLBACK TO Create_Installment_Pvt;

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

   END Create_Installment;

   ---------------------------------------------------------------------------

   PROCEDURE Update_Installment
   (
      p_init_msg_list           IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only           IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                  IN VARCHAR2   := Fnd_Api.G_False,
      p_rowid                   IN VARCHAR2,
      p_proposal_installment_id IN NUMBER,
      p_record_version_number   IN NUMBER,
      p_proposal_award_id       IN NUMBER,
      p_installment_id          IN NUMBER,
      p_installment_number      IN VARCHAR2,
      p_installment_type_desc   IN VARCHAR2,
      p_installment_type_code   IN VARCHAR2,
      p_issue_date              IN DATE,
      p_close_date              IN DATE,
      p_start_date              IN DATE,
      p_end_date                IN DATE,
      p_direct_cost             IN NUMBER,
      p_indirect_cost           IN NUMBER,
      p_billable_flag           IN VARCHAR2,
      p_description             IN VARCHAR2,
      x_return_status           OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER,
      x_msg_data                OUT NOCOPY VARCHAR2
   ) IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Update_Installment';

      l_installment_type_code  VARCHAR2(30);

      l_count                  NUMBER;
      l_return_status          VARCHAR2(1);

   BEGIN

      /*
      **   Establish Savepoint for Rollback
      */

      SAVEPOINT Update_Installment_Pvt;


      /*
      **   Initialize
      */

      x_return_status := Fnd_Api.G_Ret_Sts_Success;

      IF Fnd_Api.To_Boolean(p_init_msg_list) THEN

         Fnd_Msg_Pub.Initialize;

      END IF;


      /*
      **   Check Lock before proceeding
      */

      Check_Lock
      (
         p_rowid                  => p_rowid,
         p_record_version_number  => p_record_version_number
      );


      /*
      **   Discontinue processing if any error has been encountered during
      **   the earlier stages
      */


      IF Fnd_Msg_Pub.Count_Msg > 0 THEN

         RAISE Fnd_Api.G_Exc_Error;

      END IF;

      l_installment_type_code := Get_Gms_Lookup_Code('INSTALLMENT_TYPE',p_installment_type_desc);

      IF p_start_date > p_end_date THEN

         Fnd_Message.Set_Name('GMS','GMS_INST_ENDATE_BEF_INS_STDATE');
         Fnd_Msg_Pub.Add;

      END IF;

      IF p_end_date > p_close_date THEN

         Fnd_Message.Set_Name('GMS','GMS_INS_CLOSEDATE_BEF_ENDDATE') ;
         Fnd_Msg_Pub.Add;

      END IF;


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

      Igw_Installments_Tbh.Update_Row
      (
         p_rowid                   => p_rowid,
         p_proposal_installment_id => p_proposal_installment_id,
         p_proposal_award_id       => p_proposal_award_id,
         p_installment_id          => p_installment_id,
         p_installment_number      => p_installment_number,
         p_installment_type_code   => l_installment_type_code,
         p_issue_date              => p_issue_date,
         p_close_date              => p_close_date,
         p_start_date              => p_start_date,
         p_end_date                => p_end_date,
         p_direct_cost             => p_direct_cost,
         p_indirect_cost           => p_indirect_cost,
         p_billable_flag           => p_billable_flag,
         p_description             => p_description,
         x_return_status           => x_return_status
      );


      /*
      **   Commit data if API invoked in commit mode
      */

      IF Fnd_Api.To_Boolean(p_commit) THEN

         COMMIT;

      END IF;


   EXCEPTION

      WHEN Fnd_Api.G_Exc_Error THEN

         ROLLBACK TO Update_Installment_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN Fnd_Api.G_Exc_Unexpected_Error THEN

         ROLLBACK TO Update_Installment_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN others THEN

         ROLLBACK TO Update_Installment_Pvt;

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

   END Update_Installment;

   ---------------------------------------------------------------------------

   PROCEDURE Delete_Installment
   (
      p_init_msg_list         IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only         IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                IN VARCHAR2   := Fnd_Api.G_False,
      p_rowid                 IN VARCHAR2,
      p_record_version_number IN NUMBER,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2
   ) IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Delete_Installment';

      l_return_status          VARCHAR2(1);

   BEGIN

      /*
      **   Establish Savepoint for Rollback
      */

      SAVEPOINT Delete_Installment_Pvt;


      /*
      **   Initialize
      */

      x_return_status := Fnd_Api.G_Ret_Sts_Success;

      IF Fnd_Api.To_Boolean(p_init_msg_list) THEN

         Fnd_Msg_Pub.Initialize;

      END IF;


      /*
      **   Check Lock before proceeding
      */

      Check_Lock
      (
         p_rowid                  => p_rowid,
         p_record_version_number  => p_record_version_number
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

      Igw_Installments_Tbh.Delete_Row
      (
         p_rowid                  => p_rowid,
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

         ROLLBACK TO Delete_Installment_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN Fnd_Api.G_Exc_Unexpected_Error THEN

         ROLLBACK TO Delete_Installment_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN others THEN

         ROLLBACK TO Delete_Installment_Pvt;

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

   END Delete_Installment;

   ---------------------------------------------------------------------------

END Igw_Installments_Pvt;

/
