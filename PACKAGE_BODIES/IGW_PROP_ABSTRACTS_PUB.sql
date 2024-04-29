--------------------------------------------------------
--  DDL for Package Body IGW_PROP_ABSTRACTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_ABSTRACTS_PUB" AS
--$Header: igwpabsb.pls 115.0 2002/12/19 22:43:38 ashkumar noship $

   ---------------------------------------------------------------------------

   G_PKG_NAME  VARCHAR2(30) := 'IGW_PROP_ABSTRACTS_PUB';

   ---------------------------------------------------------------------------

   PROCEDURE Create_Prop_Abstract
   (
      p_validate_only         IN VARCHAR2,
      p_commit                IN VARCHAR2,
      p_proposal_number       IN VARCHAR2,
      p_abstract_type_desc    IN VARCHAR2,
      p_abstract              IN VARCHAR2,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2
   ) IS

      l_api_name      CONSTANT VARCHAR2(30) := 'Create_Prop_Abstract';
      l_proposal_id            IGW_PROPOSALS_ALL.PROPOSAL_ID%TYPE;
      l_abstract_type_code     IGW_PROP_ABSTRACTS.ABSTRACT_TYPE_CODE%TYPE;
      l_rowid                  VARCHAR2(60);
      l_record_version_number  NUMBER;

   BEGIN

      /*
      **   Establish Savepoint for Rollback
      */

      SAVEPOINT Create_Prop_Abstract_Pub;

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

      IF p_abstract_type_desc IS NULL THEN

         Fnd_Message.Set_Name('IGW','IGW_UPLD_MISSING_PARAMETER');
         Fnd_Message.Set_Token('PARAM_NAME','P_ABSTRACT_TYPE_DESC');
         Fnd_Msg_Pub.Add;

      ELSE

         Igw_Utils.Get_Lookup_Code
         (
            p_context_field   => 'ABSTRACT_TYPE_CODE',
            p_check_id_flag   => 'N',
            p_lookup_type     => 'IGW_ABSTRACT_TYPES',
            p_lookup_meaning  => p_abstract_type_desc,
            p_lookup_code     => null,
            x_lookup_code     => l_abstract_type_code,
            x_return_status   => x_return_status
         );

      END IF;

      IF p_abstract IS NULL THEN

         Fnd_Message.Set_Name('IGW','IGW_UPLD_MISSING_PARAMETER');
         Fnd_Message.Set_Token('PARAM_NAME','P_ABSTRACT');
         Fnd_Msg_Pub.Add;

      END IF;

      /*
      **   Discontinue processing if any error has been encountered during
      **   the earlier stages
      */

      IF Fnd_Msg_Pub.Count_Msg > 0 THEN

         RAISE Fnd_Api.G_Exc_Error;

      END IF;

      Igw_Prop_Abstracts_Pvt.Populate_Prop_Abstracts(l_proposal_id);

      /*
      **   Establish Savepoint for Rollback
      */

      SAVEPOINT Create_Prop_Abstract_Pub;

      SELECT rowid,
             record_version_number
      INTO   l_rowid,
             l_record_version_number
      FROM   igw_prop_abstracts
      WHERE  proposal_id = l_proposal_id
      AND    abstract_type = 'IGW_ABSTRACT_TYPES'
      AND    abstract_type_code = l_abstract_type_code;

      Igw_Prop_Abstracts_Pvt.Update_Prop_Abstract
      (
         p_init_msg_list         => Fnd_Api.G_True,
         p_validate_only         => p_validate_only,
         p_commit                => Fnd_Api.G_False,
         p_rowid                 => l_rowid,
         p_proposal_id           => l_proposal_id,
         p_proposal_number       => null,
         p_abstract_type         => 'IGW_ABSTRACT_TYPES',
         p_abstract_type_code    => l_abstract_type_code,
         p_abstract_type_desc    => p_abstract_type_desc,
         p_abstract              => p_abstract,
         p_attribute_category    => null,
         p_attribute1            => null,
         p_attribute2            => null,
         p_attribute3            => null,
         p_attribute4            => null,
         p_attribute5            => null,
         p_attribute6            => null,
         p_attribute7            => null,
         p_attribute8            => null,
         p_attribute9            => null,
         p_attribute10           => null,
         p_attribute11           => null,
         p_attribute12           => null,
         p_attribute13           => null,
         p_attribute14           => null,
         p_attribute15           => null,
         p_record_version_number => l_record_version_number,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data
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

         ROLLBACK TO Create_Prop_Abstract_Pub;

         x_return_status := Fnd_Api.G_Ret_Sts_Error;

         Fnd_Msg_Pub.Count_And_Get
         (
            p_encoded => Fnd_Api.G_False,
            p_count   => x_msg_count,
            p_data    => x_msg_data
         );

      WHEN others THEN

         ROLLBACK TO Create_Prop_Abstract_Pub;

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

   END Create_Prop_Abstract;

   ---------------------------------------------------------------------------

END Igw_Prop_Abstracts_Pub;

/
