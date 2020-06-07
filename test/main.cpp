#include "Bench.h"
#include "Runner.h"

#include "VRISC16.h"

int main(int argc, char** argv)
{
	TestSuite suite;
	suite.myName = "RISC16";

	bool success = suite.Execute();
	suite.Stop();

	return (success ? 0 : -1);
}