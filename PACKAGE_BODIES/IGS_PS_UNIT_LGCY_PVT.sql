--------------------------------------------------------
--  DDL for Package Body IGS_PS_UNIT_LGCY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_UNIT_LGCY_PVT" AS
/* $Header: IGSPS93B.pls 120.2 2005/09/27 01:35:52 appldev noship $ */


G_PKG_NAME     CONSTANT VARCHAR2(30) := 'igs_ps_unit_lgcy_pvt';

PROCEDURE create_unit(
             p_api_version           IN            NUMBER,
             p_init_msg_list         IN            VARCHAR2,
             p_commit                IN            VARCHAR2,
             p_validation_level      IN            NUMBER,
             x_return_status         OUT NOCOPY    VARCHAR2,
             x_msg_count             OUT NOCOPY    NUMBER,
             x_msg_data              OUT NOCOPY    VARCHAR2,
             p_unit_ver_rec          IN OUT NOCOPY igs_ps_generic_pub.unit_ver_rec_type,
             p_unit_tr_tbl           IN OUT NOCOPY igs_ps_generic_pub.unit_tr_tbl_type,
             p_unit_dscp_tbl         IN OUT NOCOPY igs_ps_generic_pub.unit_dscp_tbl_type,
             p_unit_gs_tbl           IN OUT NOCOPY igs_ps_generic_pub.unit_gs_tbl_type,
             p_usec_tbl              IN OUT NOCOPY igs_ps_generic_pub.usec_tbl_type,
             p_usec_gs_tbl           IN OUT NOCOPY igs_ps_generic_pub.usec_gs_tbl_type,
             p_uso_tbl               IN OUT NOCOPY igs_ps_generic_pub.uso_tbl_type,
             p_unit_ref_tbl          IN OUT NOCOPY igs_ps_generic_pub.unit_ref_tbl_type,
             p_uso_ins_tbl           IN OUT NOCOPY igs_ps_generic_pub.uso_ins_tbl_type  ) AS

/***********************************************************************************************
Created By:         Sanjeeb Rakshit
Date Created By:    20-Nov-2002
Purpose:            This is a public API to import data from external system to OSS.
Known limitations,enhancements,remarks:

Change History

Who         When           What
sommukhe    27-SEP-2005    BUG #4632652.FND logging included.
smvk        07-Nov-2003    Bug # 3138353. Added the call to validate_unit_dtls, which does unit level cross
                           subprocesses validation.
jbegum      02-june-2003   Bug # 2972950. Added the call to unit section occcurrence instructor sub process
                           As Mentioned in TD.
***********************************************************************************************/
l_api_name      CONSTANT VARCHAR2(30) := 'create_unit';
l_api_version   CONSTANT NUMBER := 1.0;
l_rec_status    VARCHAR2(1) :='S';
l_record_exists BOOLEAN := FALSE;
BEGIN

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_unit_lgcy_pvt.create_unit.start_logging_for',
                    'Data import from external Sysytem to OSS -LEGACY ');
  END IF;

  --Standard start of API savepoint
  SAVEPOINT Create_Unit_PVT;

  --Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version ,
                                     p_api_version ,
                                     l_api_name    ,
                                     G_PKG_NAME    )  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;


  --Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --API body
  --Call Unit Version sub process
  IF p_unit_ver_rec.unit_cd IS NOT NULL AND p_unit_ver_rec.version_number IS NOT NULL THEN
    igs_ps_unit_lgcy_pkg.create_unit_version(p_unit_ver_rec,l_rec_status);
    l_record_exists := TRUE;
    IF l_rec_status = 'E' THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  --Call the Unit teaching responsibility sub process
  IF p_unit_tr_tbl.COUNT > 0 THEN
    igs_ps_unit_lgcy_pkg.create_teach_resp( p_unit_tr_tbl,l_rec_status);
    l_record_exists := TRUE;

    IF l_rec_status = 'E' THEN
      x_return_status := 'E';
    END IF;
  END IF;


  --Call the Unit discipline sub process
  IF p_unit_dscp_tbl.COUNT > 0 THEN
    igs_ps_unit_lgcy_pkg.create_unit_discip( p_unit_dscp_tbl,l_rec_status);
    l_record_exists := TRUE;

    IF l_rec_status = 'E' THEN
      x_return_status := 'E';
    END IF;
  END IF;

  --Call the Unit grading schema sub process
  IF p_unit_gs_tbl.COUNT > 0 THEN
    igs_ps_unit_lgcy_pkg.create_unit_grd_sch( p_unit_gs_tbl,l_rec_status);
    l_record_exists := TRUE;

    IF l_rec_status = 'E' THEN
      x_return_status := 'E';
    END IF;
  END IF;

  IF NVL(p_unit_ver_rec.status,'E') = 'S' THEN
    igs_ps_unit_lgcy_pkg.validate_unit_dtls( p_unit_ver_rec, l_rec_status);
    IF l_rec_status = 'E' THEN
      x_return_status := 'E';
    END IF;
  END IF;


  --Call the Unit Section sub process
  IF p_usec_tbl.COUNT > 0 THEN
    igs_ps_unit_lgcy_pkg.create_unit_section( p_usec_tbl,l_rec_status,'L');
    l_record_exists := TRUE;

    IF l_rec_status = 'E' THEN
      x_return_status := 'E';
    END IF;
  END IF;

  --Call the Unit Section Grading schema sub process
  IF p_usec_gs_tbl.COUNT > 0 THEN
    igs_ps_unit_lgcy_pkg.create_usec_grd_sch( p_usec_gs_tbl,l_rec_status,'L');
    l_record_exists := TRUE;

    IF l_rec_status = 'E' THEN
      x_return_status := 'E';
    END IF;
  END IF;

  --Call the Unit Section Occurrence sub process
  IF p_uso_tbl.COUNT > 0 THEN

    igs_ps_unit_lgcy_pkg.create_usec_occur( p_uso_tbl,l_rec_status,'L');
    l_record_exists := TRUE;

    IF l_rec_status = 'E' THEN
      x_return_status := 'E';
    END IF;
  END IF;

  --Call the Unit Section Reference Code sub process
  IF p_unit_ref_tbl.COUNT > 0 THEN
    igs_ps_unit_lgcy_pkg.create_unit_ref_code( p_unit_ref_tbl,l_rec_status,'L');
    l_record_exists := TRUE;

    IF l_rec_status = 'E' THEN
      x_return_status := 'E';
    END IF;
  END IF;

  -- Call the Unit Section Occurence Instructors sub process
  IF p_uso_ins_tbl.COUNT > 0 THEN
     igs_ps_unit_lgcy_pkg.create_uso_ins(p_uso_ins_tbl,l_rec_status);
     l_record_exists := TRUE;

     IF l_rec_status = 'E' THEN
          x_return_status := 'E';
     END IF;
  END IF;

  --If none of the PL/SQL data has been passed then raise error
  IF NOT l_record_exists THEN
    FND_MESSAGE.SET_NAME('IGS','IGS_PS_LGCY_DATA_NOT_PASSED');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --If return status is error then raise expected exception to rollback the changes
  IF x_return_status = 'E' THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --End of API body

  --Standard check of p_commit
  IF FND_API.TO_Boolean( p_commit) THEN
    COMMIT WORK;
  END IF;

  --Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get( p_count  => x_msg_count,
                             p_data   => x_msg_data);

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_unit_lgcy_pvt.create_unit.end_of_logging_for',
                    'Data import from external Sysytem to OSS -LEGACY ');
  END IF;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Create_Unit_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count  => x_msg_count ,
                                   p_data   => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Create_Unit_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count  => x_msg_count ,
                                   p_data   => x_msg_data );

    WHEN OTHERS THEN
        ROLLBACK TO Create_Unit_PVT;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                   l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get( p_count  => x_msg_count ,
                                   p_data   => x_msg_data );
        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_exception, 'igs.plsql.igs_ps_unit_lgcy_pvt.create_unit.in_exception_section_OTHERS.err_msg',
			  SUBSTRB(SQLERRM,1,4000));
        END IF;

END create_unit;

END igs_ps_unit_lgcy_pvt;

/
