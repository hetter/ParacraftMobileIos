#pragma once

#include "cocos2d.h"

namespace NPL{
	class CNPLRuntimeState;
}

namespace ParaEngine
{
	USING_NS_CC;
	class MainLoopTimer;
	class CParaEngineApp;
	/**
	@brief    ParaCraftMobile Application.

	The reason for implement as private inheritance is to hide some interface call by Director.
	*/
	class  AppDelegate : private cocos2d::Application
	{
	public:
		AppDelegate();
		virtual ~AppDelegate();

		void StopApp();

		/**
		@brief    Implement Director and Scene init code here.
		@return true    Initialize success, app continue.
		@return false   Initialize failed, app terminate.
		*/
		virtual bool applicationDidFinishLaunching();

		bool InitApp();

		void CreateParaEngineApp();

		void GetCommandLine(std::string &sCmdLine);
        void SetMacCommandLine(std::string &sCmdLine);

		void InitNPL();

		static void OnNPLStateLoaded(NPL::CNPLRuntimeState* pRuntimeState);

		void InitSearchPath();

		void InitDirector();

		void InitDirectorScene();

		void InitParaEngineApp();

		void FrameMove(float fElapsedTime);
		/**
		@brief  The function be called when the application enter background
		@param  the pointer of the application
		*/
		virtual void applicationDidEnterBackground();

		/**
		@brief  The function be called when the application enter foreground
		@param  the pointer of the application
		*/
		virtual void applicationWillEnterForeground();
	public:
		const std::string& GetScriptSearchPath() const;
	private:
		std::string m_sScriptSearchPath;
		std::unique_ptr<MainLoopTimer> m_pMainTimer;
		std::unique_ptr<CParaEngineApp> m_pParaEngineApp;
        std::string m_MacCommandline;
		std::string m_worldUrl;
	};
}
using namespace ParaEngine;