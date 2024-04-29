--------------------------------------------------------
--  DDL for Package Body IGW_BUDGETS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_BUDGETS_PUB" AS
--$Header: igwpbvsb.pls 115.0 2002/12/19 22:43:48 ashkumar noship $

   ---------------------------------------------------------------------------

   G_PKG_NAME  VARCHAR2(30) := 'IGW_BUDGETS_PUB';

   ---------------------------------------------------------------------------

   PROCEDURE Get_Oh_Rate_Class_Id
   (
      p_oh_rate_class_name IN VARCHAR2,
      x_oh_rate_class_id   OUT NOCOPY VARCHAR2
   ) IS
   BEGIN

      IF p_oh_rate_class_name IS NOT NULL THEN

         SELECT rate_class_id
         INTO   x_oh_rate_class_id
         FROM   igw_rate_classes
         WHERE  description = p_oh_rate_class_name;

      END IF;

  EXCEPTION

      WHEN no_data_found THEN

         Fnd_Message.Set_Name('IGW','IGW_UPLD_OH_RATE_CLASS_INV');
         Fnd_Msg_Pub.Add;

   END Get_Oh_Rate_Class_Id;

   ---------------------------------------------------------------------------

   PROCEDURE Create_Budget_Version
   (
      p_validate_only                IN VARCHAR2,
      p_commit                       IN VARCHAR2,
      p_proposal_number              IN VARCHAR2,
      p_start_date                   IN DATE,
      p_end_date                     IN DATE,
      p_oh_rate_class_name           IN VARCHAR2,
      p_proposal_form_number         IN VARCHAR2,
      p_total_cost_limit             IN NUMBER,
      p_total_cost                   IN NUMBER,
      p_total_direct_cost            IN NUMBER,
      p_total_indirect_cost          IN NUMBER,
      p_cost_sharing_amount          IN NUMBER,
      p_underrecovery_amount         IN NUMBER,
      p_residual_funds               IN NUMBER,
      p_final_version_flag           IN VARCHAR2,
      p_enter_budget_at_period_level IN VARCHAR2,
      p_apply_inflation_setup_rates  IN VARCHAR2,
      p_apply_eb_setup_rates         IN VARCHAR2,
      p_apply_oh_setup_rates         IN VARCHAR2,
      p_comments                     IN VARCHAR2,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2
   ) IS

      l_api_name  CONSTANT  VARCHAR2(30) := 'Create_Budget_Version';
      l_rowid               VARCHAR2(60);
      l_proposal_id         IGW_PROPOSALS_ALL.PROPOSAL_ID%TYPE;
      l_oh_rate_class_id    IGW_BUDGETS.OH_RATE_CLASS_ID%TYPE;

   BEGIN

      /*
      **   Establish Savepoint for Rollback
      */

      SAVEPOINT Create_Budget_Version_Pub;

      /*
      **   Initialize Processing
      */

      x_return_status := Fnd_Api.G_Ret_Sts_Success;

      Fnd_Msg_Pub.Initialize;

      /*
      **   Verify Mandatory Inputs. Value-Id Conversions.
      */

      IF p_proposal_number IS NULL THEN

         Fnd_Message.Set_Name('IGW','IGW_UPLD_MISSING_PARAMETER');
         Fnd_Message.Set_Token('PARAM_NAME','P_PROPOSAL_NUMBER');
         Fnd_Msg_Pub.Add;

      ELSE

         Igw_Utils.Get_Proposal_Id
         (
            p_context_field    => 'PROPOSAL_ID',
            p_check_id_flag    => 'N',
            p_proposal_number  => p_proposal_number,
            p_proposal_id      => l_proposal_id,
            x_proposal_id      => l_proposal_id,
            x_return_status    => x_return_status
         );

      END IF;

      IF p_start_date IS NULL THEN

         Fnd_Message.Set_Name('IGW','IGW_UPLD_MISSING_PARAMETER');
         Fnd_Message.Set_Token('PARAM_NAME','P_START_DATE');
         Fnd_Msg_Pub.Add;

      END IF;

      IF p_end_date IS NULL THEN

         Fnd_Message.Set_Name('IGW','IGW_UPLD_MISSING_PARAMETER');
         Fnd_Message.Set_Token('PARAM_NAME','P_END_DATE');
         Fnd_Msg_Pub.Add;

      END IF;

      IF p_oh_rate_class_name IS NULL THEN

         Fnd_Message.Set_Name('IGW','IGW_UPLD_MISSING_PARAMETER');
         Fnd_Message.Set_Token('PARAM_NAME','P_OH_RATE_CLASS_NAME');
         Fnd_Msg_Pub.Add;

      ELSE

         Get_Oh_Rate_Class_Id
         (
            p_oh_rate_class_name => p_oh_rate_class_name,
            x_oh_rate_class_id   => l_oh_rate_class_id
         );

      END IF;

      IF p_proposal_form_number IS NULL THEN

         Fnd_Message.Set_Name('IGW','IGW_UPLD_MISSING_PARAMETER');
         Fnd_Message.Set_Token('PARAM_NAME','P_PROPOSAL_FORM_NUMBER');
         Fnd_Msg_Pub.Add;

      END IF;

      IF p_final_version_flag NOT IN ('N','Y') THEN

         Fnd_Message.Set_Name('IGW','IGW_UPLD_INVALID_FLAG');
         Fnd_Message.Set_Token('PARAM_NAME','P_FINAL_VERSION_FLAG');
         Fnd_Msg_Pub.Add;

      END IF;

      IF p_enter_budget_at_period_level NOT IN ('N','Y') THEN

         Fnd_Message.Set_Name('IGW','IGW_UPLD_INVALID_FLAG');
         Fnd_Message.Set_Token('PARAM_NAME','P_ENTER_BUDGET_AT_PERIOD_LEVEL');
         Fnd_Msg_Pub.Add;

      END IF;

      IF p_apply_inflation_setup_rates NOT IN ('N','Y') THEN

         Fnd_Message.Set_Name('IGW','IGW_UPLD_INVALID_FLAG');
         Fnd_Message.Set_Token('PARAM_NAME','P_APPLY_INFLATION_SETUP_RATES');
         Fnd_Msg_Pub.Add;

      END IF;

      IF p_apply_eb_setup_rates NOT IN ('N','Y') THEN

         Fnd_Message.Set_Name('IGW','IGW_UPLD_INVALID_FLAG');
         Fnd_Message.Set_Token('PARAM_NAME','P_APPLY_EB_SETUP_RATES');
         Fnd_Msg_Pub.Add;

      END IF;

      IF p_apply_oh_setup_rates NOT IN ('N','Y') THEN

         Fnd_Message.Set_Name('IGW','IGW_UPLD_INVALID_FLAG');
         Fnd_Message.Set_Token('PARAM_NAME','P_APPLY_OH_SETUP_RATES');
         Fnd_Msg_Pub.Add;

      END IF;

      /*
      **   Discontinue processing if any error has been encountered during
      **   the earlier stages
      */

      IF Fnd_Msg_Pub.Count_Msg > 0 THEN

         RAISE Fnd_Api.G_Exc_Error;

      END IF;

      Igw_Budgets_Pvt.Create_Budget_Version
      (
         p_init_msg_list                => Fnd_Api.G_True,
         p_commit                       => Fnd_Api.G_False,
         p_validate_only                => p_validate_only,
         p_proposal_id                  => l_proposal_id,
         p_version_id                   => null,
         p_start_date                   => p_start_date,
         p_end_date                     => p_end_date,
         p_total_cost                   => p_total_cost,
         p_total_direct_cost            => p_total_direct_cost,
         p_total_indirect_cost          => p_total_indirect_cost,
         p_cost_sharing_amount          => p_cost_sharing_amount,
         p_underrecovery_amount         => p_underrecovery_amount,
         p_residual_funds               => p_residual_funds,
         p_total_cost_limit             => p_total_cost_limit,
         p_oh_rate_class_id             => l_oh_rate_class_id,
         p_oh_rate_class_name           => null,
         p_proposal_form_number         => p_proposal_form_number,
         p_comments                     => p_comments,
         p_final_version_flag           => p_final_version_flag,
         p_budget_type_code             => 'PROPOSAL_BUDGET',
         p_enter_budget_at_period_level => p_enter_budget_at_period_level,
         p_apply_inflation_setup_rates  => p_apply_inflation_setup_rates,
         p_apply_eb_setup_rates         => p_apply_eb_setup_rates,
         p_apply_oh_setup_rates         => p_apply_oh_setup_rates,
         p_attribute_category           => null,
         p_attribute1                   => null,
         p_attribute2                   => null,
         p_attribute3                   => null,
         p_attribute4                   => null,
         p_attribute5                   => null,
         p_attribute6                   => null,
         p_attribute7                   => null,
         p_attribute8                   => null,
         p_attribute9                   => null,
         p_attribute10                  => null,
         p_attribute11                  => null,
         p_attribute12                  => null,
         p_attribute13                  => null,
         p_attribute14                  => null,
         p_attribute15                  => null,
         x_rowid                        => l_rowid,
         x_return_status                => x_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data
      );

      IF Fnd_Msg_Pub.Count_Msg > 0 THEN

         RAISE Fnd_Api.G_Exc_Error;

      END IF;


      /*
      **   Commit data if API invoked in commit mode
      */

      IF Fnd_Api.To_Boolean(p_commit) THEN

         COMMIT;

      END IF;

   EXCEPTION

      WHEN Fnd_Api.G_Exc_Error THEN

         ROLLBACK TO Create_Budget_Version_Pub;

         x_return_status := Fnd_Api.G_Ret_Sts_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_encoded => Fnd_Api.G_False,
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN others THEN

         ROLLBACK TO Create_Budget_Version_Pub;

         x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error;

         Fnd_Msg_Pub.Add_Exc_Msg
         (
            p_pkg_name       => G_PKG_NAME,
            p_procedure_name => l_api_name
         );

         Fnd_Msg_Pub.Count_And_Get
         (
            p_encoded => Fnd_Api.G_False,
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

   END Create_Budget_Version;

   ---------------------------------------------------------------------------

END Igw_Budgets_Pub;

/
