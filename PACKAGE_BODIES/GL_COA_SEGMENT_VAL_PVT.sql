--------------------------------------------------------
--  DDL for Package Body GL_COA_SEGMENT_VAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_COA_SEGMENT_VAL_PVT" AS
/* $Header: GLSVIPVB.pls 120.1.12010000.1 2009/12/16 11:53:55 sommukhe noship $ */

G_PKG_NAME     CONSTANT VARCHAR2(30) := 'gl_coa_segment_val_pvt';

PROCEDURE coa_segment_val_imp (
p_api_version			      IN           NUMBER,
p_init_msg_list			      IN           VARCHAR2 DEFAULT FND_API.G_FALSE,
p_commit			      IN           VARCHAR2 DEFAULT FND_API.G_FALSE,
p_validation_level		      IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
x_return_status		              OUT NOCOPY   VARCHAR2,
x_msg_count			      OUT NOCOPY   NUMBER,
x_msg_data			      OUT NOCOPY   VARCHAR2,
p_gl_flex_values_tbl		      IN OUT NOCOPY gl_coa_seg_val_imp_pub.gl_flex_values_tbl_type,
p_gl_flex_values_nh_tbl		      IN OUT NOCOPY gl_coa_seg_val_imp_pub.gl_flex_values_nh_tbl_type,
p_gl_flex_values_status		      OUT NOCOPY VARCHAR2,
p_gl_flex_values_nh_status	      OUT NOCOPY VARCHAR2

 ) AS
/***********************************************************************************************
Created By:         Somnath Mukherjee
Date Created By:    01-AUG-2008
Purpose:            This is a public API to import data from external system to GL.
Known limitations,enhancements,remarks:

Change History

Who         When           What
***********************************************************************************************/


l_api_name      CONSTANT VARCHAR2(30) := 'Flex_Values_import';
l_api_version   CONSTANT NUMBER := 1.0;
l_record_exists BOOLEAN := FALSE;
BEGIN

  --Standard start of API savepoint
  SAVEPOINT gl_coa_segment_val_pvt;

  --Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version ,
                                     p_api_version ,
                                     l_api_name    ,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;


  --API body


  --Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  --API body
  p_gl_flex_values_status := 'S';
  p_gl_flex_values_nh_status := 'S';


  --Similarly for all the other PL/SQL table status variable

  --Call the fnd_flex_val sub process
  IF p_gl_flex_values_tbl.COUNT > 0 THEN


	gl_coa_seg_val_imp_pkg.create_gl_coa_flex_values( p_gl_flex_values_tbl,p_gl_flex_values_status);
	l_record_exists := TRUE;
	IF p_gl_flex_values_status = 'E' THEN
		--Set the API status to 'E'
		x_return_status := 'E';
	END IF;

	FOR I in 1..p_gl_flex_values_tbl.LAST LOOP
          IF p_gl_flex_values_tbl.EXISTS(I) THEN
            IF p_gl_flex_values_tbl(I).status = 'S' THEN
              p_gl_flex_values_tbl(I).status := 'P';
	    END IF;
          END IF;
        END LOOP;

  END IF;


    --Call the fnd_flex_val_norm_hierarchy sub process
  IF p_gl_flex_values_nh_tbl.COUNT > 0 THEN
	gl_coa_seg_val_imp_pkg.create_gl_coa_flex_values_nh( p_gl_flex_values_nh_tbl,p_gl_flex_values_nh_status);
	l_record_exists := TRUE;

	IF p_gl_flex_values_nh_status = 'E' THEN
		--Set the API status to 'E'
		x_return_status := 'E';
	END IF;

	FOR I in 1..p_gl_flex_values_nh_tbl.LAST LOOP
           IF p_gl_flex_values_nh_tbl.EXISTS(I) THEN
             IF p_gl_flex_values_nh_tbl(I).status = 'S' THEN
               p_gl_flex_values_nh_tbl(I).status := 'P';
	     END IF;
           END IF;
        END LOOP;
  END IF;


  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string( fnd_log.level_procedure, 'gl.plsql.gl_coa_segment_val_pvt.Flex_Values_import.end_of_logging_for',
                    'Data import from external Sysytem to GL ');
  END IF;

  --If none of the PL/SQL data has been passed then raise error
  IF NOT l_record_exists THEN
    FND_MESSAGE.SET_NAME ('GL','GL_COA_SVI_DATA_NOT_PASSED');
    FND_MSG_PUB.ADD;
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


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Exception1:');
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count  => x_msg_count ,
                                   p_data   => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Exception2:');
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count  => x_msg_count ,
                                   p_data   => x_msg_data );

    WHEN OTHERS THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Exception3:'||SQLERRM);
        ROLLBACK ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                   l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get( p_count  => x_msg_count ,
                                   p_data   => x_msg_data );
        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_exception, 'gl.plsql.gl_coa_segment_val_pvt.Flex_Values_import.in_exception_section_OTHERS.err_msg',
			  SUBSTRB(SQLERRM,1,4000));
	END IF;

END coa_segment_val_imp;

END gl_coa_segment_val_pvt;

/
