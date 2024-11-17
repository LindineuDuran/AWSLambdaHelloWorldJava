package bookfunction.controller;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Handler for requests to Lambda function.
 */
public class BookFunction implements RequestHandler<APIGatewayProxyRequestEvent, APIGatewayProxyResponseEvent>
{
	public APIGatewayProxyResponseEvent handleRequest(final APIGatewayProxyRequestEvent request, final Context context)
	{
		Map<String, String> headers = new HashMap<>();
		headers.put("Content-Type", "application/json");
		headers.put("X-Custom-Header", "application/json");

		String httpMethod = (request == null ? "null" : request.getHttpMethod());
		System.out.printf("{ httpMethod: %s}%n", httpMethod);

		String path = (request == null ? "null" : request.getPath());
		System.out.printf("{ path: %s}%n", path);

		APIGatewayProxyResponseEvent response = new APIGatewayProxyResponseEvent().withHeaders(headers);
		response.setHeaders(Map.of("Content-Type", "application/json"));

		try
		{
			final String pageContents = this.getPageContents("https://checkip.amazonaws.com");

			if (httpMethod.equals("GET") && path.equals("/book"))
			{
				response.setStatusCode(200);
				String body = String.format("{ message: Lista todos os livros, location: %s, httpMethod: %s, path: %s}", pageContents, httpMethod, path);
				response.setBody(body);
			}
			else if (httpMethod.equals("GET") && path.matches("/book/\\w+$"))
			{
				response.setStatusCode(200);
				String body = String.format("{ message: Busca livro por ID, location: %s, httpMethod: %s, path: %s}", pageContents, httpMethod, path);
				response.setBody(body);
			}
			else if (httpMethod.equals("POST") && path.equals("/book"))
			{
				response.setStatusCode(201);
				String body = String.format("{ message: Cria Livro, location: %s, httpMethod: %s, path: %s}", pageContents, httpMethod, path);
				response.setBody(body);
			}
			else if (httpMethod.equals("PUT") && path.matches("/book/\\w+$"))
			{
				response.setStatusCode(200);
				String body = String.format("{ message: Atualiza Livro, location: %s, httpMethod: %s, path: %s}", pageContents, httpMethod, path);
				response.setBody(body);
			}
			else if (httpMethod.equals("DELETE") && path.matches("/book/\\w+$"))
			{
				response.setStatusCode(200);
				String body = String.format("{ message: Exclui Livro, location: %s, httpMethod: %s, path: %s}", pageContents, httpMethod, path);
				response.setBody(body);
			}
			else if (httpMethod.equals("GET") && path.equals("/hello"))
			{
				response.setStatusCode(200);
				String body = String.format("{ message: Hello World, location: %s, httpMethod: %s, path: %s}", pageContents, httpMethod, path);
				response.setBody(body);
			}
			else
			{
				response.setStatusCode(404);
				String body = String.format("{ message: ERRO!!!, location: %s, httpMethod: %s, path: %s}", pageContents, httpMethod, path);
				response.setBody(body);
			}

			return response;
		}
		catch (IOException e)
		{
			return response.withBody("{}").withStatusCode(500);
		}
	}

	private String getPageContents(String address) throws IOException
	{
		URL url = new URL(address);
		try (BufferedReader br = new BufferedReader(new InputStreamReader(url.openStream())))
		{
			return br.lines().collect(Collectors.joining(System.lineSeparator()));
		}
	}
}
