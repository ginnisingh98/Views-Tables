--------------------------------------------------------
--  DDL for Package Body IGW_PROJECT_FUNDINGS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROJECT_FUNDINGS_PVT" AS
--$Header: igwvapfb.pls 115.4 2002/11/19 23:45:25 ashkumar noship $

   ---------------------------------------------------------------------------

   G_PKG_NAME  VARCHAR2(30) := 'IGW_PROJECT_FUNDINGS_PVT';

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
         FROM   igw_project_fundings
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

   PROCEDURE Validate_Project_Task
   (
      p_rowid                   IN VARCHAR2,
      p_proposal_installment_id IN NUMBER,
      p_project_number          IN VARCHAR2,
      x_project_id              OUT NOCOPY NUMBER,
      p_task_number             IN VARCHAR2,
      x_task_id                 OUT NOCOPY NUMBER
   ) IS

      l_api_name         CONSTANT VARCHAR2(30) := 'Validate_Project_Task';

      l_count_budget_entry_method NUMBER;

   BEGIN

      /*
      **   Initialize
      */

      IF p_project_number IS NULL THEN

         x_project_id := NULL;

      ELSE

         BEGIN

            SELECT p.project_id
            INTO   x_project_id
            FROM   pa_lookups lk,
                   pa_projects p,
                   gms_project_types gpt,
                   pa_project_types pt
            WHERE  p.segment1 = p_project_number
            AND    pt.project_type = p.project_type
            AND    gpt.project_type = pt.project_type
            AND    p.project_status_code not in ('CLOSED' , 'UNAPPROVED')
            AND    lk.lookup_type(+) = 'ALLOWABLE FUNDING LEVEL'
            AND    lk.lookup_code(+) = pt.allowable_funding_level_code
            AND    pt.project_type_class_code in ('INDIRECT','CAPITAL')
            AND    gpt.sponsored_flag = 'Y'
            AND    p.template_flag ='N';

         EXCEPTION

            WHEN no_data_found THEN

               Fnd_Message.Set_Name('IGW','IGW_SS_BUD_PROJECT_INVALID');
               Fnd_Msg_Pub.Add;

         END;

      END IF;

      SELECT count(distinct t.cost_budget_entry_method_code)
      INTO   l_count_budget_entry_method
      FROM   pa_projects p,
             pa_project_types t
      WHERE  ((p.project_id = x_project_id) OR
              (p.project_id IN
                (SELECT project_id
                 FROM   igw_project_fundings
                 WHERE  proposal_installment_id = p_proposal_installment_id
                 AND    (p_rowid IS NULL OR rowid <> p_rowid))))
      AND    t.project_type = p.project_type;

      IF l_count_budget_entry_method > 1 THEN

         Fnd_Message.Set_Name('IGW','IGW_SS_MULT_BUD_ENTRY_METHODS');
         Fnd_Msg_Pub.Add;
         Return;

      END IF;

      IF p_task_number IS NULL THEN

         x_task_id := NULL;

      ELSE

         BEGIN

            SELECT task_id
            INTO   x_task_id
            FROM   pa_tasks_top_v
            WHERE  project_id = x_project_id
            AND    task_number = p_task_number;

         EXCEPTION

            WHEN no_data_found THEN

               Fnd_Message.Set_Name('IGW','IGW_SS_BUD_TASK_INVALID');
               Fnd_Msg_Pub.Add;

         END;

      END IF;

   EXCEPTION

      WHEN others THEN

         Fnd_Msg_Pub.Add_Exc_Msg
         (
            p_pkg_name       => G_PKG_NAME,
            p_procedure_name => l_api_name
         );

         RAISE Fnd_Api.G_Exc_Unexpected_Error;

   END Validate_Project_Task;

   ---------------------------------------------------------------------------

   PROCEDURE Create_Project_Funding
   (
      p_init_msg_list           IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only           IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                  IN VARCHAR2   := Fnd_Api.G_False,
      x_rowid                   OUT NOCOPY VARCHAR2,
      x_proposal_funding_id     OUT NOCOPY NUMBER,
      p_proposal_installment_id IN NUMBER,
      p_project_number          IN VARCHAR2,
      p_project_id              IN NUMBER,
      p_task_number             IN VARCHAR2,
      p_task_id                 IN NUMBER,
      p_funding_amount          IN NUMBER,
      p_date_allocated          IN DATE,
      x_return_status           OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER,
      x_msg_data                OUT NOCOPY VARCHAR2
   ) IS

      l_api_name    CONSTANT VARCHAR2(30) := 'Create_Project_Funding';

      l_project_id           NUMBER;
      l_task_id              NUMBER;

      l_count                NUMBER;
      l_return_status        VARCHAR2(1);

   BEGIN

      /*
      **   Establish Savepoint for Rollback
      */

      SAVEPOINT Create_Project_Funding_Pvt;


      /*
      **   Initialize
      */

      x_return_status := Fnd_Api.G_Ret_Sts_Success;

      IF Fnd_Api.To_Boolean(p_init_msg_list) THEN

         Fnd_Msg_Pub.Initialize;

      END IF;


      Validate_Project_Task
      (
         p_rowid                   => null,
         p_proposal_installment_id => p_proposal_installment_id,
         p_project_number          => p_project_number,
         x_project_id              => l_project_id,
         p_task_number             => p_task_number,
         x_task_id                 => l_task_id
      );


      /*
      **   Discontinue processing if any error has been encountered during
      **   the earlier stages
      */

      IF Fnd_Msg_Pub.Count_Msg > 0 THEN

         RAISE Fnd_Api.G_Exc_Error;

      END IF;

      SELECT count(1)
      INTO   l_count
      FROM   igw_project_fundings
      WHERE  proposal_installment_id = p_proposal_installment_id
      AND    project_id = l_project_id
      AND    ((task_id IS NOT NULL AND l_task_id IS NULL) OR
              (task_id IS NULL AND l_task_id IS NOT NULL));

      IF l_count > 0 THEN

         Fnd_Message.Set_Name('IGW','IGW_SS_PROJECT_FUNDING_LEVEL');
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

      Igw_Project_Fundings_Tbh.Insert_Row
      (
         x_rowid                   => x_rowid,
         x_proposal_funding_id     => x_proposal_funding_id,
         p_proposal_installment_id => p_proposal_installment_id,
         p_project_id              => l_project_id,
         p_task_id                 => l_task_id,
         p_funding_amount          => p_funding_amount,
         p_date_allocated          => p_date_allocated,
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

         ROLLBACK TO Create_Project_Funding_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN Fnd_Api.G_Exc_Unexpected_Error THEN

         ROLLBACK TO Create_Project_Funding_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN others THEN

         ROLLBACK TO Create_Project_Funding_Pvt;

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

   END Create_Project_Funding;

   ---------------------------------------------------------------------------

   PROCEDURE Update_Project_Funding
   (
      p_init_msg_list           IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only           IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                  IN VARCHAR2   := Fnd_Api.G_False,
      p_rowid                   IN VARCHAR2,
      p_proposal_funding_id     IN NUMBER,
      p_record_version_number   IN NUMBER,
      p_proposal_installment_id IN NUMBER,
      p_project_number          IN VARCHAR2,
      p_project_id              IN NUMBER,
      p_task_number             IN VARCHAR2,
      p_task_id                 IN NUMBER,
      p_funding_amount          IN NUMBER,
      p_date_allocated          IN DATE,
      x_return_status           OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER,
      x_msg_data                OUT NOCOPY VARCHAR2
   ) IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Update_Project_Funding';

      l_project_id             NUMBER;
      l_task_id                NUMBER;

      l_count                  NUMBER;
      l_return_status          VARCHAR2(1);

   BEGIN

      /*
      **   Establish Savepoint for Rollback
      */

      SAVEPOINT Update_Project_Funding_Pvt;


      /*
      **   Initialize
      */

      x_return_status := Fnd_Api.G_Ret_Sts_Success;

      IF Fnd_Api.To_Boolean(p_init_msg_list) THEN

         Fnd_Msg_Pub.Initialize;

      END IF;


      Validate_Project_Task
      (
         p_rowid                   => p_rowid,
         p_proposal_installment_id => p_proposal_installment_id,
         p_project_number          => p_project_number,
         x_project_id              => l_project_id,
         p_task_number             => p_task_number,
         x_task_id                 => l_task_id
      );

      IF Fnd_Msg_Pub.Count_Msg > 0 THEN

         RAISE Fnd_Api.G_Exc_Error;

      END IF;

      SELECT count(1)
      INTO   l_count
      FROM   igw_project_fundings
      WHERE  proposal_installment_id = p_proposal_installment_id
      AND    project_id = l_project_id
      AND    rowid <> p_rowid
      AND    ((task_id IS NOT NULL AND l_task_id IS NULL) OR
              (task_id IS NULL AND l_task_id IS NOT NULL));

      IF l_count > 0 THEN

         Fnd_Message.Set_Name('IGW','IGW_SS_PROJECT_FUNDING_LEVEL');
         Fnd_Msg_Pub.Add;
         RAISE Fnd_Api.G_Exc_Error;

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
      **   Invoke Table Handler to Update data
      */

      Igw_Project_Fundings_Tbh.Update_Row
      (
         p_rowid                   => p_rowid,
         p_proposal_funding_id     => p_proposal_funding_id,
         p_proposal_installment_id => p_proposal_installment_id,
         p_project_id              => l_project_id,
         p_task_id                 => l_task_id,
         p_funding_amount          => p_funding_amount,
         p_date_allocated          => p_date_allocated,
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

         ROLLBACK TO Update_Project_Funding_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN Fnd_Api.G_Exc_Unexpected_Error THEN

         ROLLBACK TO Update_Project_Funding_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN others THEN

         ROLLBACK TO Update_Project_Funding_Pvt;

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

   END Update_Project_Funding;

   ---------------------------------------------------------------------------

   PROCEDURE Delete_Project_Funding
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

      l_api_name      CONSTANT VARCHAR2(30) := 'Delete_Project_Funding';

      l_return_status          VARCHAR2(1);

   BEGIN

      /*
      **   Establish Savepoint for Rollback
      */

      SAVEPOINT Delete_Project_Funding_Pvt;


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

      Igw_Project_Fundings_Tbh.Delete_Row
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

         ROLLBACK TO Delete_Project_Funding_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN Fnd_Api.G_Exc_Unexpected_Error THEN

         ROLLBACK TO Delete_Project_Funding_Pvt;

         x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN others THEN

         ROLLBACK TO Delete_Project_Funding_Pvt;

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

   END Delete_Project_Funding;

   ---------------------------------------------------------------------------

END Igw_Project_Fundings_Pvt;

/
