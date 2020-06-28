#include "Bench.h"
#include "Runner.h"

#include "VRISC16.h"

class Simple : public Test, public TestBench<VRISC16>
{
public:
	Simple() : Test("Simple RISC 16"), TestBench(99, "simple.vcd") {}

	void Initialize() override {
		// fibonacci:
		myMemory[0x0400] = 0x4040;
		myMemory[0x0401] = 0x6a01;
		myMemory[0x0402] = 0x6c0a;
		myMemory[0x0403] = 0x6e00;
		myMemory[0x0404] = 0x6600;

		// loop:
		myMemory[0x0405] = 0xc301;
		myMemory[0x0406] = 0x690e;
		myMemory[0x0407] = 0x6104;
		myMemory[0x0408] = 0x8301;

		myMemory[0x0409] = 0xc233;
		myMemory[0x040a] = 0x4db0;
		myMemory[0x040b] = 0x4f20;
		myMemory[0x040c] = 0x8698;

		// end:
		myMemory[0x040d] = 0x0001;

		// cal:
		myMemory[0x040e] = 0xc401;
		myMemory[0x040f] = 0x42ca;
		myMemory[0x0410] = 0x4050;
		myMemory[0x0411] = 0x4098;
		myMemory[0x0412] = 0x8400;
	}

	bool Execute() override
	{
		myCore->aReset = 1;
		Tick();
		myCore->aReset = 0;
		Tick();

		while(!myCore->RISC16__DOT__haltState && !myCore->RISC16__DOT__errorState)
		{
			if(myCore->anOutWrite)
			{
				printf("Write [%#04x] - %#04x\n", myCore->anOutAddress, myCore->anOutData);
				myMemory[myCore->anOutAddress] = myCore->anOutData;
			}
			else
			{
				printf("Read [%#04x] - %#04x\n", myCore->anOutAddress, myMemory[myCore->anOutAddress]);
				myCore->aData = myMemory[myCore->anOutAddress];
			}
			Tick();
		}

		if(myCore->RISC16__DOT__errorState)
			printf("Panic state!\n");

		return true;
	}

	void Tick() override
	{
		myCore->eval();
		DumpTrace();
		myCore->aClock = 1;
		myCore->eval();
		DumpTrace();
		myCore->aClock = 0;
	}

	void Clean() override
	{
		for(uint i = 0; i < 20; ++i)
		{
			printf("%i - %i\n", i, myMemory[i]);
		}


		delete this;
	}

private:
	uint16_t myMemory[65535];
};

int main(int argc, char** argv)
{
    Verilated::commandArgs(argc, argv);
	Verilated::traceEverOn(true);
	
	TestSuite suite;
	suite.myName = "RISC16";
	suite.myTests.emplace_back(new Simple());

	bool success = suite.Execute();
	suite.Stop();

	return (success ? 0 : -1);
}