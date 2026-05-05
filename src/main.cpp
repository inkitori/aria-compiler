#include <iostream>
#include <fstream>
#include <vector>
#include <sstream>
#include <memory>

#include "scanner.hpp"
#include "parser.hpp"
#include "ast.hpp"
#include "visitor.hpp"

using namespace std;

void scan_tokens(string);

int main()
{
	Scanner scanner("gcd.aria");
	std::vector<Token> tokens = scanner.Scan();
	scanner.PrintTokens();

	Parser parser(tokens);
	std::vector<std::unique_ptr<AST>> programAST = parser.GenAST();

	PrinterVisitor ASTPrinter;
	for (int i = 0; i < programAST.size(); i++)
	{
		programAST[i]->Accept(&ASTPrinter);
	}

	CodeGenVisitor ToASM;
	for (int i = 0; i < programAST.size(); i++)
	{
		programAST[i]->Accept(&ToASM);
	}

	ToASM.OutputASM();
}